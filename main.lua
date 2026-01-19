local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
-- Lucide Icons
local Lucide = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/main/source.lua"))()

if playerGui:FindFirstChild("MacFinderLib") then
	playerGui.MacFinderLib:Destroy()
end

local Library = {}
Library.__index = Library

function Library.CreateWindow(options)
	local self = setmetatable({}, Library)

    self.Title  = options.Title
    self.Folder = options.Folder 

	if type(options) == "string" then
		options = { Title = options }
	end
	options = options or {}

	local title = options.Title or "MacFinderLib"
	local size = options.Size or UDim2.fromOffset(650, 450)
	local theme = options.Theme or "Light"
	local position = options.Position or UDim2.fromScale(0.5, 0.5)
	local dockIcon = options.DockIcon or "external-link"
	
	self.HeadFontSize = options.HeadFontSize or 14
	self.BodyFontSize = options.BodyFontSize or 12

	-- Root
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "MacFinderLib"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.IgnoreGuiInset = true
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.ScreenGui.DisplayOrder = 100000
	self.ScreenGui.Parent = playerGui

	self.Container = Instance.new("Frame")
	self.Container.Name = "Container"
	self.Container.Size = UDim2.fromScale(1, 1)
	self.Container.Position = UDim2.fromScale(0.5, 0.5)
	self.Container.AnchorPoint = Vector2.new(0.5, 0.5)
	self.Container.BackgroundTransparency = 1
	self.Container.Parent = self.ScreenGui
	self.Scale = 1

	if UserInputService.TouchEnabled then
		local uiScale = Instance.new("UIScale")
		uiScale.Scale = 0.7
		uiScale.Parent = self.Container
		self.Scale = 0.7
	end

	self.IsMinimized = false
	self.IsMaximized = false
	self.PreMaxSize = size
	self.PreMaxPos = position
	self.OriginalSize = size

	-- Cleanup System
	self.Connections = {}
	self.ScreenGui.Destroying:Connect(function()
		for _, c in ipairs(self.Connections) do
			if c.Disconnect then pcall(function() c:Disconnect() end) end
		end
	end)

	-- Config System
	self.Flags = {}
	self.ConfigUpdates = {}
	
	self.Switch = setmetatable({}, {
		__index = function(_, key)
			return self.Flags[key]
		end,
		__newindex = function(_, key, value)
			self.Flags[key] = value
			if self.ConfigUpdates[key] then
				self.ConfigUpdates[key](value)
			end
		end
	})
	
	function self:SaveConfig(name)
		local path = name
		if self.Folder then
			if not isfolder(self.Folder) then makefolder(self.Folder) end
			path = self.Folder .. "/" .. name
		end
		local json = HttpService:JSONEncode(self.Flags)
		writefile(path .. ".json", json)
	end
	
	function self:LoadConfig(name)
		local path = name
		if self.Folder then
			path = self.Folder .. "/" .. name
		end
		if isfile(path .. ".json") then
			local json = readfile(path .. ".json")
			local data = HttpService:JSONDecode(json)
			task.wait() -- Wait for a frame to let UI elements initialize
			for k, v in pairs(data) do
				self.Flags[k] = v
				if self.ConfigUpdates[k] then
					self.ConfigUpdates[k](v)
				end
			end
			-- Add a delayed refresh to ensure UI updates
			task.delay(0.1, function()
				for k, v in pairs(data) do
					if self.ConfigUpdates[k] then
						self.ConfigUpdates[k](v)
					end
				end
			end)
		end
	end

	-- Theme System
	self.Themes = {
		Light = {
			Main = Color3.fromRGB(246, 246, 246),     -- #F2F2F7, secondary background like Control Center panel
			Sidebar = Color3.fromRGB(246, 246, 246),  -- #E5E5EA, lighter gray for sides
			Text = Color3.fromRGB(0, 0, 0),           -- #000000, primary label
			TextSub = Color3.fromRGB(142, 142, 147),  -- #8E8E93, secondary/tertiary label
			ElementBG = Color3.fromRGB(243, 242, 242),-- #FFFFFF, element fill
			Accent = Color3.fromRGB(0, 122, 255),     -- #007AFF, system accent blue
			Stroke = Color3.fromRGB(219, 218, 218),   -- #D1D1D6, separator/stroke
			TextBtn = Color3.fromRGB(255, 255, 255),  -- #FFFFFF, button text
			ToggleInactive = Color3.fromRGB(229, 229, 234), -- #E5E5EA, inactive toggle
			ScrollBar = Color3.fromRGB(199, 199, 204),-- #C7C7CC, scrollbar
			ButtomDrag = Color3.fromRGB(242, 242, 247)-- #F2F2F7, drag handle to match main
		},
		Dark = {
			Main = Color3.fromRGB(30, 30, 30),
			Sidebar = Color3.fromRGB(25, 25, 25),
			Text = Color3.fromRGB(255, 255, 255),
			TextSub = Color3.fromRGB(170, 170, 170),
			ElementBG = Color3.fromRGB(38, 38, 38),
			Accent = Color3.fromRGB(10, 132, 255),
			Stroke = Color3.fromRGB(60, 60, 60),
			TextBtn = Color3.fromRGB(255, 255, 255),
			ToggleInactive = Color3.fromRGB(60, 60, 60),
			ScrollBar = Color3.fromRGB(120, 120, 120),
			ButtomDrag = Color3.fromRGB(225, 223, 225)
		},
		Purple = {
			Main = Color3.fromRGB(35, 30, 45),
			Sidebar = Color3.fromRGB(28, 22, 38),
			Text = Color3.fromRGB(255, 255, 255),
			TextSub = Color3.fromRGB(180, 160, 200),
			ElementBG = Color3.fromRGB(50, 40, 65),
			Accent = Color3.fromRGB(140, 80, 255),
			Stroke = Color3.fromRGB(70, 60, 90),
			TextBtn = Color3.fromRGB(255, 255, 255),
			ToggleInactive = Color3.fromRGB(70, 60, 90),
			ScrollBar = Color3.fromRGB(140, 120, 160),
			DragBar = Color3.fromRGB(225, 223, 225)
		}
	}
	self.ThemeObjects = {}
	self.CurrentTheme = self.Themes[theme] or self.Themes.Light

	-- Keybind System
	self.ToggleKey = options.ToggleKey
	
	-- Main Window 
	self.Main = Instance.new("CanvasGroup")
	self.Main.Name = "Main"
	self.Main.Size = self.OriginalSize
	self.Main.Position = position
	self.Main.AnchorPoint = Vector2.new(0.5, 0.5)
	self.Main.Parent = self.Container
	
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 14) 
	mainCorner.Parent = self.Main

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Transparency = 0.5
	mainStroke.Parent = self.Main

	-- Shadow (Floating Effect)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 1
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.4
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceScale = 1
	shadow.ZIndex = self.Main.ZIndex - 1
	shadow.Parent = self.Container

	-- Header Area (Drag Zone)
	self.Header = Instance.new("Frame")
	self.Header.Name = "Header"
	self.Header.Size = UDim2.new(1, 0, 0, 55)
	self.Header.BackgroundTransparency = 1
	self.Header.ZIndex = 2
	self.Header.Active = true
	self.Header.Parent = self.Main

	-- Sidebar Header (Static background for top left)
	local sbHeader = Instance.new("Frame")
	sbHeader.Name = "SidebarHeader"
	sbHeader.Size = UDim2.new(0, 180, 0, 95) -- Increased height for search bar
	sbHeader.Position = UDim2.new(0, 0, 0, 0)
	sbHeader.BackgroundTransparency = 0.2
	sbHeader.BorderSizePixel = 0
	sbHeader.Parent = self.Main

    -- [NEW] Search Bar
    local searchContainer = Instance.new("Frame", sbHeader)
    searchContainer.Name = "SearchContainer"
    searchContainer.Size = UDim2.new(0.85, 0, 0, 28)
    searchContainer.Position = UDim2.new(0.5, 0, 0, 55)
    searchContainer.AnchorPoint = Vector2.new(0.5, 0)
    searchContainer.BackgroundTransparency = 0.5
    searchContainer.BackgroundColor3 = Color3.fromRGB(0,0,0) -- Will be themed
    
    local searchCorner = Instance.new("UICorner", searchContainer)
    searchCorner.CornerRadius = UDim.new(0, 6)
    
    local searchIcon = Instance.new("ImageLabel", searchContainer)
    searchIcon.Size = UDim2.fromOffset(14, 14)
    searchIcon.Position = UDim2.new(0, 8, 0.5, 0)
    searchIcon.AnchorPoint = Vector2.new(0, 0.5)
    searchIcon.BackgroundTransparency = 1
    local sIconInfo = Lucide.GetAsset("search")
    if sIconInfo then
        searchIcon.Image = sIconInfo.Url
        searchIcon.ImageRectSize = sIconInfo.ImageRectSize
        searchIcon.ImageRectOffset = sIconInfo.ImageRectOffset
    end

    local searchInput = Instance.new("TextBox", searchContainer)
    searchInput.Size = UDim2.new(1, -30, 1, 0)
    searchInput.Position = UDim2.new(0, 28, 0, 0)
    searchInput.BackgroundTransparency = 1
    searchInput.PlaceholderText = "Search"
    searchInput.Text = ""
    searchInput.TextXAlignment = Enum.TextXAlignment.Left
    searchInput.Font = Enum.Font.Gotham
    searchInput.TextSize = 13
    
    -- Search Logic moved after Sidebar creation

	-- Sidebar Separator (Line that appears when scrolling)
	local sidebarSeparator = Instance.new("Frame")
	sidebarSeparator.Name = "SidebarSeparator"
	sidebarSeparator.Size = UDim2.new(0, 180, 0, 1)
	sidebarSeparator.Position = UDim2.new(0, 0, 0, 95) -- Moved down
	sidebarSeparator.BackgroundTransparency = 1
	sidebarSeparator.BorderSizePixel = 0
	sidebarSeparator.ZIndex = 5
	sidebarSeparator.Parent = self.Main

	-- Sidebar
	self.Sidebar = Instance.new("ScrollingFrame")
	self.Sidebar.Name = "Sidebar"
	self.Sidebar.Size = UDim2.new(0, 180, 1, -95) -- Adjusted size
	self.Sidebar.Position = UDim2.new(0, 0, 0, 95) -- Adjusted pos
	self.Sidebar.BackgroundTransparency = 0.2
	self.Sidebar.BorderSizePixel = 0
	self.Sidebar.ScrollBarThickness = 3
	self.Sidebar.ScrollBarImageTransparency = 1
	self.Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.Sidebar.ZIndex = 2
	self.Sidebar.Parent = self.Main
	
    -- Finish Search Logic
    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchInput.Text:lower()
        for _, child in ipairs(self.Sidebar:GetChildren()) do
            if child:IsA("TextButton") then
                local found = false
                if child.Text:lower():find(query) then
                    found = true
                else
                    local container = self.ContentArea:FindFirstChild(child.Name .. "Container")
                    if container then
                        for _, desc in ipairs(container:GetDescendants()) do
                            if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and desc.Text:lower():find(query) then
                                found = true
                                break
                            end
                        end
                    end
                end
                child.Visible = found
            end
        end
    end)

	local sidebarFadeTween
	self.Sidebar:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		sidebarSeparator.BackgroundTransparency = (self.Sidebar.CanvasPosition.Y > 5) and 0 or 1
		if sidebarFadeTween then sidebarFadeTween:Cancel() end
		self.Sidebar.ScrollBarImageTransparency = 0.7
		sidebarFadeTween = TweenService:Create(self.Sidebar, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.5), {ScrollBarImageTransparency = 1})
		sidebarFadeTween:Play()
	end)

	local sidebarLayout = Instance.new("UIListLayout", self.Sidebar)
	sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sidebarLayout.Padding = UDim.new(0, 5)
	sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Instance.new("UIPadding", self.Sidebar).PaddingTop = UDim.new(0, 10)

	-- Content Area
	self.ContentArea = Instance.new("Frame")
	self.ContentArea.Name = "ContentArea"
	self.ContentArea.Size = UDim2.new(1, -180, 1, 0)
	self.ContentArea.Position = UDim2.new(0, 180, 0, 0)
	self.ContentArea.BackgroundTransparency = 1
	self.ContentArea.BorderSizePixel = 0
	self.ContentArea.Parent = self.Main

	-- Theme Functions
	function self:AddThemeObject(obj, properties)
		table.insert(self.ThemeObjects, {Object = obj, Properties = properties})
		self:ApplyThemeToObject(obj, properties)
	end

	function self:ApplyThemeToObject(obj, properties)
		local theme = self.CurrentTheme
		for prop, typeOrFunc in pairs(properties) do
			if type(typeOrFunc) == "function" then
				typeOrFunc(obj, theme)
			elseif theme[typeOrFunc] then
				obj[prop] = theme[typeOrFunc]
			end
		end
	end

	function self:SetTheme(themeName)
		self.CurrentTheme = self.Themes[themeName] or self.Themes.Light
		for _, item in ipairs(self.ThemeObjects) do
			self:ApplyThemeToObject(item.Object, item.Properties)
		end
	end

	-- Icon Helper
	function self:CreateIcon(parent, iconName, pos, size)
		if not iconName then return end
		local info = Lucide.GetAsset(iconName)
		if not info then
			return
		end

		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Size = size or UDim2.fromOffset(20, 20)
		icon.Position = pos or UDim2.new(0, -28, 0.5, 0)
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.BackgroundTransparency = 1
		icon.Image = info.Url
		icon.ImageRectSize = info.ImageRectSize
		icon.ImageRectOffset = info.ImageRectOffset
		icon.ZIndex = (parent.ZIndex or 1) + 1
		icon.Parent = parent
		self:AddThemeObject(icon, {ImageColor3 = "Text"})
		return icon
	end

	-- Traffic Lights 
	local traffic = Instance.new("Frame")
	traffic.Size = UDim2.fromOffset(90, 60)
	traffic.Position = UDim2.fromOffset(18, 0)
	traffic.BackgroundTransparency = 1
	traffic.ZIndex = 10
	traffic.Parent = self.Main
	
	local tLayout = Instance.new("UIListLayout", traffic)
	tLayout.FillDirection = Enum.FillDirection.Horizontal
	tLayout.Padding = UDim.new(0, 13) -- ระยะห่างระหว่างปุ่ม
	tLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	-- Popup System
	function self:ShowPopup(titleText, msgText, onConfirm, onCancel)
		local overlay = Instance.new("Frame", self.Container)
		overlay.Name = "PopupOverlay"
		overlay.Size = UDim2.fromScale(1 / self.Scale, 1 / self.Scale)
		overlay.Position = UDim2.fromScale(0.5, 0.5)
		overlay.AnchorPoint = Vector2.new(0.5, 0.5)
		overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		overlay.BackgroundTransparency = 1
		overlay.ZIndex = 100
		TweenService:Create(overlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()

		local box = Instance.new("Frame", overlay)
		box.Size = UDim2.fromOffset(0, 0) -- Start small
		box.Position = UDim2.fromScale(0.5, 0.5)
		box.AnchorPoint = Vector2.new(0.5, 0.5)
		box.ClipsDescendants = true
		Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)
		
		local content = Instance.new("Frame", box)
		content.Size = UDim2.fromScale(1, 1)
		content.BackgroundTransparency = 1
		
		local title = Instance.new("TextLabel", content)
		title.Text = titleText
		title.Size = UDim2.new(1, 0, 0, 40)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 18
		title.BackgroundTransparency = 1
		
		local msg = Instance.new("TextLabel", content)
		msg.Text = msgText
		msg.Size = UDim2.new(1, -20, 0, 40)
		msg.Position = UDim2.fromOffset(10, 40)
		msg.Font = Enum.Font.Gotham
		msg.TextSize = 14
		msg.BackgroundTransparency = 1
		msg.TextWrapped = true

		self:AddThemeObject(box, {BackgroundColor3 = "Main"})
		self:AddThemeObject(title, {TextColor3 = "Text"})
		self:AddThemeObject(msg, {TextColor3 = "TextSub"})

		local function createBtn(text, color, callback)
			local btn = Instance.new("TextButton", content)
			btn.Size = UDim2.new(0.4, 0, 0, 30)
			btn.BackgroundColor3 = color
			btn.Text = text
			btn.Font = Enum.Font.GothamMedium
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.TextSize = 14
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
			btn.MouseButton1Click:Connect(function()
				TweenService:Create(overlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
				TweenService:Create(box, TweenInfo.new(0.2), {Size = UDim2.fromOffset(0, 0)}):Play()
				task.wait(0.2)
				overlay:Destroy()
				if callback then callback() end
			end)
			return btn
		end

		local yes = createBtn("Confirm", self.CurrentTheme.Accent, onConfirm)
		yes.Position = UDim2.new(0.5, 5, 1, -40)
		
		local no = createBtn("Cancel", self.CurrentTheme.ToggleInactive, onCancel)
		no.Position = UDim2.new(0.1, 0, 1, -40)

		TweenService:Create(box, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(280, 140)}):Play()
	end

	-- Notification System
	local notifyHolder = Instance.new("Frame", self.ScreenGui)
	notifyHolder.Name = "Notifications"
	notifyHolder.Size = UDim2.new(0, 250, 1, -20)
	notifyHolder.Position = UDim2.new(1, -20, 0, 10)
	notifyHolder.AnchorPoint = Vector2.new(1, 0)
	notifyHolder.BackgroundTransparency = 1
	notifyHolder.ZIndex = 100

	if UserInputService.TouchEnabled then
		local nScale = Instance.new("UIScale", notifyHolder)
		nScale.Scale = 0.7
	end
	
	local nLayout = Instance.new("UIListLayout", notifyHolder)
	nLayout.Padding = UDim.new(0, 10)
	nLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	nLayout.SortOrder = Enum.SortOrder.LayoutOrder

	function self:Notify(titleText, descriptionText, duration)
		local frame = Instance.new("Frame", notifyHolder)
		frame.Size = UDim2.new(1, 0, 0, 60)
		frame.BackgroundTransparency = 0.1
		frame.Position = UDim2.fromOffset(300, 0) -- Start off screen
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
		local stroke = Instance.new("UIStroke", frame)

		local titleLabel = Instance.new("TextLabel", frame)
		titleLabel.Text = titleText
		titleLabel.Size = UDim2.new(1, -20, 0, 25)
		titleLabel.Position = UDim2.fromOffset(10, 5)
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 14
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.BackgroundTransparency = 1

		local descriptionLabel = Instance.new("TextLabel", frame)
		descriptionLabel.Text = descriptionText
		descriptionLabel.Size = UDim2.new(1, -20, 0, 25)
		descriptionLabel.Position = UDim2.fromOffset(10, 28)
		descriptionLabel.Font = Enum.Font.Gotham
		descriptionLabel.TextSize = 13
		descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
		descriptionLabel.BackgroundTransparency = 1

		self:AddThemeObject(frame, {BackgroundColor3 = "ElementBG"})
		self:AddThemeObject(stroke, {Color = "Stroke"})
		self:AddThemeObject(titleLabel, {TextColor3 = "Text"})
		self:AddThemeObject(descriptionLabel, {TextColor3 = "TextSub"})

		TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.fromOffset(0, 0)}):Play()
		
		task.delay(duration or 3, function()
			TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}):Play()
			TweenService:Create(titleLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {TextTransparency = 1}):Play()
			TweenService:Create(descriptionLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {TextTransparency = 1}):Play()
			TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Transparency = 1}):Play()
			task.wait(0.5)
			frame:Destroy()
		end)
	end

	local function makeDot(color, action)
		local btn = Instance.new("TextButton", traffic)
		btn.Size = UDim2.fromOffset(20, 20) -- Larger touch area
		btn.Text = ""
		btn.BackgroundTransparency = 1
		btn.AutoButtonColor = false
		btn.MouseButton1Click:Connect(action)

		local visualDot = Instance.new("Frame", btn)
		visualDot.Size = UDim2.fromOffset(13, 13)
		visualDot.Position = UDim2.fromScale(0.5, 0.5)
		visualDot.AnchorPoint = Vector2.new(0.5, 0.5)
		visualDot.BackgroundColor3 = color
		Instance.new("UICorner", visualDot).CornerRadius = UDim.new(1, 0)
	end

	-- Dock System (Top Center)
	self.Dock = Instance.new("TextButton")
	self.Dock.Name = "Dock"
	self.Dock.Text = ""
	self.Dock.AutomaticSize = Enum.AutomaticSize.X
	self.Dock.Size = UDim2.fromOffset(0, 32)
	self.Dock.Position = UDim2.new(0.5, 0, 0, 2)
	self.Dock.AnchorPoint = Vector2.new(0.5, 0)
	self.Dock.BackgroundColor3 = self.CurrentTheme.Main
	self.Dock.Visible = false
	self.Dock.Parent = self.ScreenGui -- Parent to ScreenGui to avoid container scaling issues
	self.Dock.ZIndex = 300
	
	local dockLayout = Instance.new("UIListLayout", self.Dock)
	dockLayout.FillDirection = Enum.FillDirection.Horizontal
	dockLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	dockLayout.Padding = UDim.new(0, 10)
	
	local dockPadding = Instance.new("UIPadding", self.Dock)
	dockPadding.PaddingLeft = UDim.new(0, 12)
	dockPadding.PaddingRight = UDim.new(0, 12)

	local dockCorner = Instance.new("UICorner", self.Dock)
	dockCorner.CornerRadius = UDim.new(1, 0)
	
	local dockStroke = Instance.new("UIStroke", self.Dock)
	dockStroke.Color = self.CurrentTheme.Stroke
	dockStroke.Transparency = 0
	dockStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	self:AddThemeObject(self.Dock, {BackgroundColor3 = "Main"})
	self:AddThemeObject(dockStroke, {Color = "Stroke"})

	local dIcon = self:CreateIcon(self.Dock, dockIcon, UDim2.fromScale(0,0))
	if dIcon then dIcon.LayoutOrder = 1 end

	local dockSeparator = Instance.new("Frame", self.Dock)
	dockSeparator.Name = "Separator"
	dockSeparator.Size = UDim2.new(0, 1, 0, 20)
	dockSeparator.BorderSizePixel = 0
	dockSeparator.LayoutOrder = 2
	self:AddThemeObject(dockSeparator, {BackgroundColor3 = "Stroke"})

	local dockLabel = Instance.new("TextLabel", self.Dock)
	dockLabel.AutomaticSize = Enum.AutomaticSize.X
	dockLabel.Size = UDim2.new(0, 0, 1, 0)
	dockLabel.BackgroundTransparency = 1
	dockLabel.Text = title
	dockLabel.Font = Enum.Font.GothamBold
	dockLabel.TextSize = 14
	dockLabel.TextXAlignment = Enum.TextXAlignment.Left
	dockLabel.LayoutOrder = 3
	self:AddThemeObject(dockLabel, {TextColor3 = "Text"})

	self.Dock.MouseButton1Click:Connect(function()
		self.Dock.Visible = false
		self.Main.Visible = true
	end)

	-- Dragging Logic
	local dragging, dragStart, startPos
	self.Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = self.Main.Position
		end
	end)

	-- Bottom Drag Bar (External)
	local dragBar = Instance.new("Frame", self.Container)
	dragBar.Name = "DragBar"
	dragBar.Size = UDim2.fromOffset(200, 4)
	dragBar.AnchorPoint = Vector2.new(0.5, 0)
	dragBar.BackgroundColor3 = self.CurrentTheme.ButtomDrag
	dragBar.BackgroundTransparency = 0.3
	dragBar.ZIndex = 25
	dragBar.Active = true
	Instance.new("UICorner", dragBar).CornerRadius = UDim.new(1, 0)
	self:AddThemeObject(dragBar, {BackgroundColor3 = "ButtomDrag"})

	dragBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = self.Main.Position
		end
	end)

	-- Resize Borders (เส้นขอบสำหรับย่อขยาย)
	local resizeRight = Instance.new("Frame", self.Main)
	resizeRight.Name = "ResizeRight"
	resizeRight.Size = UDim2.new(0, 10, 1, -20)
	resizeRight.Position = UDim2.new(1, -10, 0, 0)
	resizeRight.BackgroundTransparency = 1
	resizeRight.ZIndex = 20

	local resizeBottom = Instance.new("Frame", self.Main)
	resizeBottom.Name = "ResizeBottom"
	resizeBottom.Size = UDim2.new(1, -20, 0, 10)
	resizeBottom.Position = UDim2.new(0, 0, 1, -10)
	resizeBottom.BackgroundTransparency = 1
	resizeBottom.ZIndex = 20

	-- Resize Handle (External)
	local resizeHandle = Instance.new("Frame", self.Container)
	resizeHandle.Name = "ResizeHandle"
	resizeHandle.Position = UDim2.new(0, 0, 0, 0) -- Synced in syncShadow
	resizeHandle.AnchorPoint = Vector2.new(1, 1)
	resizeHandle.BackgroundTransparency = 1
	resizeHandle.ZIndex = 200
	resizeHandle.Size = UDim2.fromOffset(20, 20) -- Interaction area

	local arcContainer = Instance.new("Frame", resizeHandle)
	arcContainer.Name = "ArcContainer"
	arcContainer.Size = UDim2.fromOffset(30, 30)
	arcContainer.Position = UDim2.fromOffset(2, 2)
	arcContainer.AnchorPoint = Vector2.new(0, 0)
	arcContainer.BackgroundTransparency = 1
	arcContainer.ClipsDescendants = true

	local arcCircle = Instance.new("Frame", arcContainer)
	arcCircle.Name = "ArcCircle"
	arcCircle.Size = UDim2.fromOffset(30, 30)
	arcCircle.Position = UDim2.fromOffset(-13, -13)
	arcCircle.BackgroundTransparency = 1
	Instance.new("UICorner", arcCircle).CornerRadius = UDim.new(1, 0)

	local arcStroke = Instance.new("UIStroke", arcCircle)
	arcStroke.Thickness = 4
	arcStroke.Color = self.CurrentTheme.ButtomDrag
	arcStroke.Transparency = 0.3
	self:AddThemeObject(arcStroke, {Color = "ButtomDrag"})

	local resizing = false
	local resizeDir = "Both" -- Both, X, Y
	local rStartSize, rStartPos
	local currentResizeInput

	local function startResize(input, dir)
		resizing = true
		currentResizeInput = input
		resizeDir = dir or "Both"
		rStartPos = input.Position
		rStartSize = self.Main.Size
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End and input == currentResizeInput then 
				resizing = false 
				currentResizeInput = nil
			end
		end)
	end

	resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			startResize(input, "Both")
		end
	end)

	resizeRight.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			startResize(input, "X")
		end
	end)

	resizeBottom.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			startResize(input, "Y")
		end
	end)

	table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		elseif resizing then
			local isTouch = currentResizeInput.UserInputType == Enum.UserInputType.Touch
			local isValid = (isTouch and input == currentResizeInput) or (not isTouch and input.UserInputType == Enum.UserInputType.MouseMovement)
			
			if isValid then
				local delta = (input.Position - rStartPos) / self.Scale
				local newX = rStartSize.X.Offset
				local newY = rStartSize.Y.Offset
				
				if resizeDir == "Both" or resizeDir == "X" then
					newX = math.max(450, newX + delta.X)
				end
				if resizeDir == "Both" or resizeDir == "Y" then
					newY = math.max(300, newY + delta.Y)
				end

				local newSize = UDim2.fromOffset(newX, newY)
				self.Main.Size = newSize
				self.OriginalSize = newSize
			end
		end
	end))

	table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			resizing = false
		end
	end))

	-- Sync Visibility (External Elements)
	local function syncVisibility()
		local visible = self.Main.Visible
		shadow.Visible = visible
		dragBar.Visible = visible and not self.IsMaximized
		resizeHandle.Visible = visible and not self.IsMaximized
	end
	self.Main:GetPropertyChangedSignal("Visible"):Connect(syncVisibility)
	
	makeDot(Color3.fromRGB(255, 95, 87), function() 
		self:ShowPopup("Close Window", "Are you sure you want to close?", function() self.ScreenGui:Destroy() end)
	end)
	-- Yellow: Maximize / Restore
	makeDot(Color3.fromRGB(255, 189, 46), function()
		if self.IsMaximized then
			TweenService:Create(self.Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = self.PreMaxSize, Position = self.PreMaxPos}):Play()
			self.IsMaximized = false
		else
			self.PreMaxSize = self.Main.Size
			self.PreMaxPos = self.Main.Position
			self.IsMaximized = true
			local scaleMult = 1 / self.Scale
			
			local topInset = GuiService:GetGuiInset().Y
			local newSize = UDim2.new(scaleMult, -40, scaleMult, -40 - topInset)
			local newPos = UDim2.new(0.5, 0, 0.5, topInset / 2)

			TweenService:Create(self.Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = newSize, Position = newPos}):Play()
		end
		syncVisibility()
	end)

	-- Green: Minimize to Dock
	makeDot(Color3.fromRGB(40, 201, 64), function() 
		self.Main.Visible = false
		self.Dock.Visible = true
	end)

	-- Sync Shadow Position & Size
	local function syncShadow()
		shadow.Position = self.Main.Position
		shadow.Size = self.Main.Size + UDim2.fromOffset(40, 40)
		dragBar.Position = self.Main.Position + UDim2.new(0, 0, 0, self.Main.Size.Y.Offset / 2 + 6)
		resizeHandle.Position = self.Main.Position + UDim2.new(0, self.Main.Size.X.Offset / 2 + 6, 0, self.Main.Size.Y.Offset / 2 + 6)
	end
	self.Main:GetPropertyChangedSignal("Position"):Connect(syncShadow)
	self.Main:GetPropertyChangedSignal("Size"):Connect(syncShadow)
	syncShadow()

	-- Apply Initial Theme
	self:AddThemeObject(self.Main, {BackgroundColor3 = "Main"})
	self:AddThemeObject(mainStroke, {Color = "Stroke"})
	self:AddThemeObject(sidebarSeparator, {BackgroundColor3 = "Stroke"})
	self:AddThemeObject(sbHeader, {BackgroundColor3 = "Sidebar"})
	self:AddThemeObject(self.Sidebar, {BackgroundColor3 = "Sidebar", ScrollBarImageColor3 = "ScrollBar"})
    self:AddThemeObject(searchContainer, {BackgroundColor3 = "ElementBG"})
    self:AddThemeObject(searchIcon, {ImageColor3 = "TextSub"})
    self:AddThemeObject(searchInput, {TextColor3 = "Text", PlaceholderColor3 = "TextSub"})


	-- Global Keybind Listener
	table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == self.ToggleKey then
			if self.Main.Visible then
				self.Main.Visible = false
				self.Dock.Visible = true
			else
				self.Main.Visible = true
				self.Dock.Visible = false
			end
		end
	end))

	self.Tabs = {}
	self.TabCount = 0
	self.ActiveTab = nil
	self.ActivePage = nil
	return self
end

function Library:CreateTab(name, subtitle, iconName)
	if type(name) == "table" then
		local options = name
		name = options.Name
		subtitle = options.Subtitle
		iconName = options.Icon
	end

	local window = self
	window.TabCount = window.TabCount + 1
	local tabBtn = Instance.new("TextButton", self.Sidebar)
	tabBtn.LayoutOrder = window.TabCount
	tabBtn.Name = name
	tabBtn.ZIndex = 2
	tabBtn.Size = UDim2.new(0.92, 0, 0, 32)
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = name
	tabBtn.Font = Enum.Font.GothamMedium
	tabBtn.TextSize = 15
	tabBtn.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

	local padding = Instance.new("UIPadding", tabBtn)
	if iconName then
		window:CreateIcon(tabBtn, iconName) -- ใช้ค่า Default จาก CreateIcon
		padding.PaddingLeft = UDim.new(0, 38)
	else
		padding.PaddingLeft = UDim.new(0, 12)
	end

	-- Container
	local container = Instance.new("Frame", self.ContentArea)
	container.Name = name .. "Container"
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.Visible = false

	-- Page (ScrollingFrame)
	local page = Instance.new("ScrollingFrame", container)
	page.Name = name .. "Page"
	page.Size = UDim2.new(1, -6, 1, -55) -- ลดขนาดลงนิดนึงให้ Scrollbar ลอย
	page.Position = UDim2.new(0, 0, 0, 55)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.ScrollBarThickness = 3
	page.ScrollBarImageTransparency = 1 -- เริ่มต้นซ่อน
	
	local pageLayout = Instance.new("UIListLayout", page)
	pageLayout.Padding = UDim.new(0, 15) -- ระยะห่างระหว่าง Group
	pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	local pagePadding = Instance.new("UIPadding", page)
	pagePadding.PaddingLeft = UDim.new(0, 25) -- เพิ่มระยะห่าง
	pagePadding.PaddingRight = UDim.new(0, 20) -- ลดขวาลงนิดนึงเพราะ Scrollbar ลอยเข้ามา
	pagePadding.PaddingTop = UDim.new(0, 20)
	pagePadding.PaddingBottom = UDim.new(0, 10)
	
	-- Tab Header (Fixed at top)
	local headFrame = Instance.new("Frame", container)
	headFrame.Name = "Header"
	headFrame.Size = UDim2.new(1, 0, 0, 55)
	headFrame.BackgroundTransparency = 1
	Instance.new("UIPadding", headFrame).PaddingLeft = UDim.new(0, 25)
	
	local headerLayout = Instance.new("UIListLayout", headFrame)
	headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	headerLayout.Padding = UDim.new(0, 0)
	
	local title = Instance.new("TextLabel", headFrame)
	title.Text = name
	title.Size = UDim2.new(1, 0, 0, 25)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.BackgroundTransparency = 1

	local sub = Instance.new("TextLabel", headFrame)
	sub.Text = subtitle or "Mac Finder Interface"
	sub.Size = UDim2.new(1, 0, 0, 15)
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 14
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.BackgroundTransparency = 1

	-- Divider Line 
	local divider = Instance.new("Frame", container)
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.new(0, 0, 0, 55)
	divider.BackgroundTransparency = 1 -- เริ่มต้นซ่อน (เหมือนฝั่งซ้าย)
	divider.BorderSizePixel = 0

	-- Theme Registration
	window:AddThemeObject(tabBtn, {
		BackgroundColor3 = "Accent",
		TextColor3 = function(obj, theme)
			obj.TextColor3 = (window.ActiveTab == obj) and theme.TextBtn or theme.TextSub
		end
	})
	window:AddThemeObject(title, {TextColor3 = "Text"})
	window:AddThemeObject(sub, {TextColor3 = "TextSub"})
	window:AddThemeObject(divider, {BackgroundColor3 = "Stroke"})
	window:AddThemeObject(page, {ScrollBarImageColor3 = "ScrollBar"})

	-- Scrollbar Fade & Divider Logic
	local contentFadeTween
	page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		-- Show divider when scrolling
		divider.BackgroundTransparency = (page.CanvasPosition.Y > 5) and 0 or 1

		if contentFadeTween then contentFadeTween:Cancel() end
		page.ScrollBarImageTransparency = 0.7
		contentFadeTween = TweenService:Create(page, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.5), {ScrollBarImageTransparency = 1})
		contentFadeTween:Play()
	end)

	local function selectThis()
		if self.ActivePage then self.ActivePage.Visible = false end
		if self.ActiveTab then 
			self.ActiveTab.BackgroundTransparency = 1 
			self.ActiveTab.TextColor3 = window.CurrentTheme.TextSub
		end
		container.Visible = true
		tabBtn.BackgroundTransparency = 0
		tabBtn.TextColor3 = window.CurrentTheme.TextBtn
		self.ActivePage = container
		self.ActiveTab = tabBtn
	end

	tabBtn.MouseButton1Click:Connect(selectThis)

	local Elements = {}

	local function createRipple(btn, x, y)
		local circle = Instance.new("ImageLabel")
		circle.Name = "Ripple"
		circle.Parent = btn
		circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		circle.BackgroundTransparency = 1
		circle.Image = "rbxassetid://266543268"
		circle.ImageColor3 = Color3.fromRGB(0, 0, 0)
		circle.ImageTransparency = 0.8
		circle.Position = UDim2.new(0, x, 0, y)
		circle.Size = UDim2.new(0, 0, 0, 0)
		circle.AnchorPoint = Vector2.new(0.5, 0.5)
		
		local size = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.5
		local tween = TweenService:Create(circle, TweenInfo.new(0.5), {Size = UDim2.new(0, size, 0, size), ImageTransparency = 1})
		tween:Play()
		tween.Completed:Connect(function() circle:Destroy() end)
	end

	function Elements:SelectTab()
		selectThis()
	end

	local function updateGroupSeparators(group)
		local frames = {}
		for _, child in ipairs(group:GetChildren()) do
			if child:IsA("Frame") or child:IsA("TextButton") then
				table.insert(frames, child)
			end
		end
		table.sort(frames, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
		
		for i, frame in ipairs(frames) do
			local separator = frame:FindFirstChild("Separator")
			if separator then
				separator.Visible = (i < #frames)
			end
		end
	end

	local elementCount = 0
	local currentGroup = nil
	local function getGroup()
		if currentGroup then return currentGroup end
		elementCount = elementCount + 1
		local group = Instance.new("Frame", page)
		group.Name = "Group"
		group.LayoutOrder = elementCount
		group.Size = UDim2.new(1, 0, 0, 0)
		group.AutomaticSize = Enum.AutomaticSize.Y
		group.BackgroundColor3 = window.CurrentTheme.ElementBG
		group.BorderSizePixel = 0
		group.ClipsDescendants = true
		
		local corner = Instance.new("UICorner", group)
		corner.CornerRadius = UDim.new(0, 10)
		
		local stroke = Instance.new("UIStroke", group)
		stroke.Color = window.CurrentTheme.Stroke
		stroke.Transparency = 0.6
		window:AddThemeObject(stroke, {Color = "Stroke"})

		local layout = Instance.new("UIListLayout", group)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 0)
		
		window:AddThemeObject(group, {BackgroundColor3 = "ElementBG"})
		currentGroup = group
		return group
	end

	local function endGroup()
		currentGroup = nil
	end

	function Elements:Button(options)
		local text = options.Title or "Button"
		local callback = options.Callback or function() end
		local icon = options.Icon

		local parent = getGroup()
		local frame = Instance.new("Frame", parent)
		frame.Size = UDim2.new(1, 0, 0, 42)
		frame.BackgroundTransparency = 1

		local btn = Instance.new("TextButton", frame)
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.Text = text
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 15
		btn.ClipsDescendants = true
		btn.BackgroundTransparency = 1
		
		local padding = Instance.new("UIPadding", btn)
		padding.PaddingLeft = UDim.new(0, 15)
		if icon then
			window:CreateIcon(btn, icon)
			padding.PaddingLeft = UDim.new(0, 40)
		end
		btn.MouseButton1Click:Connect(callback)
		
		local arrow = Instance.new("TextLabel", frame)
		arrow.Text = "く"
		arrow.Rotation = 180
		arrow.AnchorPoint = Vector2.new(1, 0.5)
		arrow.Size = UDim2.new(0, 30, 0, 30)
		arrow.Position = UDim2.new(1, -10, 0.5, 0)
		arrow.BackgroundTransparency = 1
		arrow.Font = Enum.Font.GothamBold
		arrow.TextSize = 16
		window:AddThemeObject(arrow, {TextColor3 = "TextSub"})

		local separator = Instance.new("Frame", frame)
		separator.Name = "Separator"
		separator.Size = UDim2.new(1, 0, 0, 1)
		separator.Position = UDim2.new(0, 0, 1, -1)
		separator.BorderSizePixel = 0
		separator.BackgroundTransparency = 0.8 -- Fainter separator
		window:AddThemeObject(separator, {BackgroundColor3 = "Stroke"})

		window:AddThemeObject(btn, {
			TextColor3 = "Text"
		})

		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local x = input.Position.X - btn.AbsolutePosition.X
				local y = input.Position.Y - btn.AbsolutePosition.Y
				if window.Scale and window.Scale ~= 1 then
					x = x / window.Scale
					y = y / window.Scale
				end
				createRipple(btn, x, y)
			end
		end)
		updateGroupSeparators(parent)
	end

	function Elements:Toggle(options)
		local text = options.Title or "Toggle"
		local callback = options.Callback or function() end
		local default = options.Default or false
		local icon = options.Icon
		local flag = options.Flag

		if flag then
			if window.Flags[flag] ~= nil then
				default = window.Flags[flag]
			else
				window.Flags[flag] = default
			end
		end

		local parent = getGroup()
		local frame = Instance.new("Frame", parent)
		frame.Size = UDim2.new(1, 0, 0, 42)
		frame.BackgroundTransparency = 0
		
		local label = Instance.new("TextLabel", frame)
		label.Text = text
		label.Size = UDim2.new(1, -50, 1, 0)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 15
		
		local padding = Instance.new("UIPadding", label)
		padding.PaddingLeft = UDim.new(0, 15)
		if icon then
			window:CreateIcon(frame, icon, UDim2.new(0, 12, 0.5, 0))
			padding.PaddingLeft = UDim.new(0, 40)
		end

		local switch = Instance.new("TextButton", frame)
		switch.Size = UDim2.fromOffset(36, 20)
		switch.Position = UDim2.new(1, -45, 0.5, 0)
		switch.AnchorPoint = Vector2.new(0, 0.5)
		switch.Text = ""
		Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

		local knob = Instance.new("Frame", switch)
		knob.Size = UDim2.fromOffset(16, 16)
		knob.Position = default and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2)
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

		local active = default
		
		local separator = Instance.new("Frame", frame)
		separator.Name = "Separator"
		separator.Size = UDim2.new(1, 0, 0, 1)
		separator.Position = UDim2.new(0, 0, 1, -1)
		separator.BorderSizePixel = 0
		separator.BackgroundTransparency = 0.8
		window:AddThemeObject(separator, {BackgroundColor3 = "Stroke"})

		frame.BackgroundTransparency = 1
		window:AddThemeObject(label, {TextColor3 = "Text"})
		window:AddThemeObject(knob, {BackgroundColor3 = "TextBtn"})
		window:AddThemeObject(switch, {
			BackgroundColor3 = function(obj, theme) obj.BackgroundColor3 = active and theme.Accent or theme.ToggleInactive end
		})

		switch.MouseButton1Click:Connect(function()
			active = not active
			if flag then window.Flags[flag] = active end
			local theme = window.CurrentTheme
			TweenService:Create(knob, TweenInfo.new(0.25), {Position = active and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2)}):Play()
			TweenService:Create(switch, TweenInfo.new(0.25), {BackgroundColor3 = active and theme.Accent or theme.ToggleInactive}):Play()
			callback(active)
		end)

		if flag then
			window.ConfigUpdates[flag] = function(newVal)
				active = newVal
				local theme = window.CurrentTheme
				TweenService:Create(knob, TweenInfo.new(0.25), {Position = active and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2)}):Play()
				TweenService:Create(switch, TweenInfo.new(0.25), {BackgroundColor3 = active and theme.Accent or theme.ToggleInactive}):Play()
				callback(newVal)
			end
		end
		updateGroupSeparators(parent)
	end

	function Elements:Slider(options)
		local text = options.Title or "Slider"
		local min = options.Min or 0
		local max = options.Max or 100
		local default = options.Default or min
		local callback = options.Callback or function() end
		local icon = options.Icon
		local flag = options.Flag

		if flag then
			if window.Flags[flag] ~= nil then
				default = window.Flags[flag]
			else
				window.Flags[flag] = default
			end
		end

		local parent = getGroup()
		local frame = Instance.new("Frame", parent)
		frame.Size = UDim2.new(1, 0, 0, 42)
		frame.BackgroundTransparency = 0
		
		local label = Instance.new("TextLabel", frame)
		label.Text = text .. ": " .. default
		label.Size = UDim2.new(0.4, -10, 1, 0)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 15

		local padding = Instance.new("UIPadding", label)
		padding.PaddingLeft = UDim.new(0, 15)
		if icon then
			window:CreateIcon(frame, icon, UDim2.new(0, 12, 0.5, 0))
			padding.PaddingLeft = UDim.new(0, 40)
		end

		local sliderContainer = Instance.new("Frame", frame)
		sliderContainer.Size = UDim2.new(0.6, 0, 1, 0)
		sliderContainer.Position = UDim2.new(1, -10, 0, 0)
		sliderContainer.AnchorPoint = Vector2.new(1, 0)
		sliderContainer.BackgroundTransparency = 1
		sliderContainer.Active = true

		local bar = Instance.new("Frame", sliderContainer)
		bar.Size = UDim2.new(1, -20, 0, 5) 
		bar.Position = UDim2.fromScale(0.5, 0.5)
		bar.AnchorPoint = Vector2.new(0.5, 0.5)
		Instance.new("UICorner", bar)

		local fill = Instance.new("Frame", bar)
		fill.Size = UDim2.fromScale(math.clamp((default-min)/(max-min), 0, 1), 1)
		Instance.new("UICorner", fill)

		local knob = Instance.new("TextButton", bar)
		knob.Size = UDim2.fromOffset(18, 18)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.Position = UDim2.fromScale(fill.Size.X.Scale, 0.5)
		knob.Text = ""
		knob.BackgroundTransparency = 1
		
		local knobShadow = Instance.new("ImageLabel", knob)
		knobShadow.Name = "Shadow"
		knobShadow.AnchorPoint = Vector2.new(0.5, 0.5)
		knobShadow.Position = UDim2.fromScale(0.5, 0.5)
		knobShadow.Size = UDim2.new(1, 10, 1, 10)
		knobShadow.BackgroundTransparency = 1
		knobShadow.Image = "rbxassetid://6014261993"
		knobShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
		knobShadow.ImageTransparency = 0.6
		knobShadow.SliceCenter = Rect.new(49, 49, 450, 450)
		knobShadow.ScaleType = Enum.ScaleType.Slice
		knobShadow.ZIndex = 1
		
		local knobVisual = Instance.new("Frame", knob)
		knobVisual.Size = UDim2.fromScale(1, 1)
		knobVisual.ZIndex = 2
		Instance.new("UICorner", knobVisual).CornerRadius = UDim.new(1, 0)
		local knobStroke = Instance.new("UIStroke", knobVisual)

		local separator = Instance.new("Frame", frame)
		separator.Name = "Separator"
		separator.Size = UDim2.new(1, 0, 0, 1)
		separator.Position = UDim2.new(0, 0, 1, -1)
		separator.BorderSizePixel = 0
		separator.BackgroundTransparency = 0.8
		window:AddThemeObject(separator, {BackgroundColor3 = "Stroke"})

		frame.BackgroundTransparency = 1
		window:AddThemeObject(label, {TextColor3 = "Text"})
		window:AddThemeObject(bar, {BackgroundColor3 = "ToggleInactive"})
		window:AddThemeObject(fill, {BackgroundColor3 = "Accent"})
		window:AddThemeObject(knobVisual, {BackgroundColor3 = "ElementBG"})
		window:AddThemeObject(knobStroke, {Color = "Stroke"})

		local dragging = false
		local page = parent.Parent 

		local function update(input)
			local inputX = input.Position.X
			local barAbsX = bar.AbsolutePosition.X
			local barAbsSizeX = bar.AbsoluteSize.X
			
			if barAbsSizeX == 0 then return end

			local percent = math.clamp((inputX - barAbsX) / barAbsSizeX, 0, 1)
			
			fill.Size = UDim2.fromScale(percent, 1)
			knob.Position = UDim2.fromScale(percent, 0.5)
			local value = math.floor(min + (max - min) * percent + 0.5)
			label.Text = text .. ": " .. value
			if flag then window.Flags[flag] = value end
			callback(value)
		end

		local function startDrag()
			dragging = true
			if page and page:IsA("ScrollingFrame") then
				page.ScrollingEnabled = false
			end
		end
		
		local function endDrag()
			if not dragging then return end
			dragging = false
			if page and page:IsA("ScrollingFrame") then
				page.ScrollingEnabled = true
			end
		end

		knob.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				startDrag()
			end
		end)

		bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				startDrag()
				update(input) -- Immediately jump to position
			end
		end)

		table.insert(window.Connections, UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				update(input)
			end
		end))

		table.insert(window.Connections, UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				endDrag()
			end
		end))

		if flag then
			window.ConfigUpdates[flag] = function(newVal)
				local value = math.clamp(tonumber(newVal) or default, min, max)
				local percent = (value - min) / (max - min)
				fill.Size = UDim2.fromScale(percent, 1)
				knob.Position = UDim2.fromScale(percent, 0.5)
				label.Text = text .. ": " .. value
				callback(value)
			end
		end
		updateGroupSeparators(parent)
	end

	function Elements:Dropdown(options)
		local text = options.Title or "Dropdown"
		local values = options.Values or {}
		local multi = options.Multi or false
		local default = options.Default or (multi and {} or values[1])
		local callback = options.Callback or function() end
		local icon = options.Icon
		local flag = options.Flag

		if flag then
			if window.Flags[flag] ~= nil then
				default = window.Flags[flag]
			else
				window.Flags[flag] = default
			end
		end

        -- Ensure default is table if multi
        if multi and type(default) ~= "table" then default = {default} end

		local parent = getGroup()
		local frame = Instance.new("Frame", parent)
		frame.Size = UDim2.new(1, 0, 0, 42)
		frame.BackgroundTransparency = 0

		local label = Instance.new("TextLabel", frame)
		label.Text = text
		label.Size = UDim2.new(0.4, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 15

		local padding = Instance.new("UIPadding", label)
		padding.PaddingLeft = UDim.new(0, 15)
		if icon then
			window:CreateIcon(frame, icon, UDim2.new(0, 12, 0.5, 0))
			padding.PaddingLeft = UDim.new(0, 40)
		end

        local function getValText()
            if multi then
                if #default == 0 then return "None" end
                return table.concat(default, ", ")
            else
                return tostring(default)
            end
        end

		-- Value Button (Click to open popup)
		local valueBtn = Instance.new("TextButton", frame)
		valueBtn.Size = UDim2.new(0, 200, 0, 28)
		valueBtn.Position = UDim2.new(1, -10, 0.5, 0)
		valueBtn.AnchorPoint = Vector2.new(1, 0.5)
		valueBtn.BackgroundTransparency = 1
		valueBtn.Text = getValText()
		valueBtn.TextXAlignment = Enum.TextXAlignment.Right -- Right Align
		valueBtn.Font = Enum.Font.Gotham
		valueBtn.TextSize = 14
        valueBtn.ClipsDescendants = true
		Instance.new("UICorner", valueBtn).CornerRadius = UDim.new(0, 6)
		Instance.new("UIPadding", valueBtn).PaddingRight = UDim.new(0, 25) -- Space for arrow

		-- Selector Box (Arrows)
		local arrowBox = Instance.new("Frame", valueBtn) 
		arrowBox.Size = UDim2.new(0, 20, 0, 20)
		arrowBox.Position = UDim2.new(1, 0, 0.5, 0)
		arrowBox.AnchorPoint = Vector2.new(0, 0.5)
		arrowBox.BackgroundTransparency = 1 -- Transparent
		Instance.new("UICorner", arrowBox).CornerRadius = UDim.new(0, 4)

		local upBtn = Instance.new("TextButton", arrowBox)
		upBtn.Size = UDim2.new(1, 0, 0.5, 0)
        upBtn.Position = UDim2.new(0,0,0,0)
        upBtn.AnchorPoint = Vector2.new(0,0)
		upBtn.BackgroundTransparency = 1
		upBtn.Text = ""
        window:CreateIcon(upBtn, "chevron-up", UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(14,14))

		local downBtn = Instance.new("TextButton", arrowBox)
		downBtn.Size = UDim2.new(1, 0, 0.5, 0)
		downBtn.Position = UDim2.new(0, 0, 1, 0)
        downBtn.AnchorPoint = Vector2.new(0, 1)
		downBtn.BackgroundTransparency = 1
		downBtn.Text = ""
        window:CreateIcon(downBtn, "chevron-down", UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(14,14))

		local separator = Instance.new("Frame", frame)
		separator.Name = "Separator"
		separator.Size = UDim2.new(1, 0, 0, 1)
		separator.Position = UDim2.new(0, 0, 1, -1)
		separator.BorderSizePixel = 0
		separator.BackgroundTransparency = 0.8
		window:AddThemeObject(separator, {BackgroundColor3 = "Stroke"})

		frame.BackgroundTransparency = 1
		window:AddThemeObject(label, {TextColor3 = "Text"})
		window:AddThemeObject(valueBtn, {TextColor3 = "TextSub", BackgroundColor3 = "Text"})
		-- window:AddThemeObject(arrowBox, {BackgroundColor3 = "Accent"}) -- Removed

		local function updateValue(v)
            if multi then
                -- Toggle
                local idx = table.find(default, v)
                if idx then
                    table.remove(default, idx)
                else
                    table.insert(default, v)
                end
            else
			    default = v
            end
            
            valueBtn.Text = getValText()
			if flag then window.Flags[flag] = default end
			callback(default)
		end

		-- Popup Logic
		valueBtn.MouseButton1Click:Connect(function()
        if window.DropdownOpen then return end
        window.DropdownOpen = true

        local overlay = Instance.new("TextButton", window.Container)
        overlay.Name = "DropdownOverlay"
        overlay.Size = UDim2.fromScale(1, 1)
        overlay.BackgroundTransparency = 1
        overlay.Text = ""
        overlay.AutoButtonColor = false
        overlay.Selectable = false
        overlay.ZIndex = 200

        local popup = Instance.new("ScrollingFrame", window.Container)
        popup.Name = "DropdownPopup"
        popup.Size = UDim2.fromOffset(valueBtn.AbsoluteSize.X, 0)
        popup.Position = UDim2.fromOffset(
            valueBtn.AbsolutePosition.X,
            valueBtn.AbsolutePosition.Y + valueBtn.AbsoluteSize.Y + 5,
            valueBtn.AbsolutePosition.X / window.Scale,
            (valueBtn.AbsolutePosition.Y + valueBtn.AbsoluteSize.Y + 5) / window.Scale
        )
        popup.BackgroundColor3 = window.CurrentTheme.ElementBG
        popup.ZIndex = 201
        popup.ClipsDescendants = true
        popup.CanvasSize = UDim2.new(0, 0, 0, 0)
        popup.AutomaticCanvasSize = Enum.AutomaticSize.Y
        popup.ScrollBarThickness = 4
        popup.ScrollBarImageColor3 = window.CurrentTheme.ScrollBar
        popup.BorderSizePixel = 0

        local popupCorner = Instance.new("UICorner", popup)
        popupCorner.CornerRadius = UDim.new(0, 10)

        local stroke = Instance.new("UIStroke", popup)
        stroke.Color = window.CurrentTheme.Stroke
        stroke.Transparency = 0.6

        local padding = Instance.new("UIPadding", popup)
        padding.PaddingTop = UDim.new(0, 4)
        padding.PaddingBottom = UDim.new(0, 4)
        padding.PaddingLeft = UDim.new(0, 4)
        padding.PaddingRight = UDim.new(0, 8) -- More padding for scrollbar

        local layout = Instance.new("UIListLayout", popup)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 2)

        local function close()
            if overlay then overlay:Destroy() end
            if popup then popup:Destroy() end
            window.DropdownOpen = false
        end

        overlay.MouseButton1Click:Connect(close)

        for i, v in ipairs(values) do
            local isSelected = false
            if multi then
                isSelected = table.find(default, v) ~= nil
            else
                isSelected = (tostring(v) == tostring(default))
            end

            local btn = Instance.new("TextButton", popup)
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.Text = ""
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.Selectable = false
            btn.SelectionImageObject = nil
            btn.ClipsDescendants = true
            btn.ZIndex = popup.ZIndex + 1
            btn.BackgroundColor3 = window.CurrentTheme.Accent
            btn.BackgroundTransparency = 1

            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 6)

            local check = Instance.new("TextLabel", btn)
            check.Size = UDim2.new(0, 30, 1, 0)
            check.BackgroundTransparency = 1
            check.Text = "✔"
            check.Font = Enum.Font.GothamBold
            check.TextSize = 12
            check.TextColor3 = window.CurrentTheme.Text
            check.Visible = isSelected

            local label = Instance.new("TextLabel", btn)
            label.Size = UDim2.new(1, -35, 1, 0)
            label.Position = UDim2.new(0, 35, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = tostring(v)
            label.Font = isSelected and Enum.Font.GothamBold or Enum.Font.GothamMedium
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextColor3 = window.CurrentTheme.Text

            -- REMOVED INTERNAL SEPARATOR

            btn.MouseEnter:Connect(function()
                btn.BackgroundTransparency = 0.15
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                check.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)

            btn.MouseLeave:Connect(function()
                btn.BackgroundTransparency = 1
                label.TextColor3 = window.CurrentTheme.Text
                check.TextColor3 = window.CurrentTheme.Text
            end)

            btn.MouseButton1Down:Connect(function()
                local c = window.CurrentTheme.Accent
                btn.BackgroundColor3 = Color3.fromRGB(
                    math.clamp(c.R * 255 - 40, 0, 255),
                    math.clamp(c.G * 255 - 40, 0, 255),
                    math.clamp(c.B * 255 - 40, 0, 255)
                )
            end)

            btn.MouseButton1Click:Connect(function()
                updateValue(v)
                if multi then
                     isSelected = table.find(default, v) ~= nil
                     check.Visible = isSelected
                     label.Font = isSelected and Enum.Font.GothamBold or Enum.Font.GothamMedium
                     btn.BackgroundColor3 = window.CurrentTheme.Accent
                     btn.BackgroundTransparency = 0.15
                else
                    close()
                end
            end)
        end
        local newHeight = math.min(#values * 30 + 10, 200) -- Cap height for scrolling
        popup.Size = UDim2.fromOffset(valueBtn.AbsoluteSize.X, newHeight)
    end)

		-- Cycle Logic (Disabled for Multi)
        local function cycle(dir)
            if multi then return end -- Disable cycling logic for multi
            local current = tostring(default)
            local idx = 1
            for i, v in ipairs(values) do
                if tostring(v) == current then
                    idx = i
                    break
                end
            end
            
            idx = idx + dir
            if idx < 1 then idx = #values elseif idx > #values then idx = 1 end
            updateValue(values[idx])
        end

        upBtn.MouseButton1Click:Connect(function() cycle(-1) end)
        downBtn.MouseButton1Click:Connect(function() cycle(1) end)

		if flag then
			window.ConfigUpdates[flag] = function(newVal)
				if multi and type(newVal) ~= "table" then newVal = {newVal} end
                default = newVal
				valueBtn.Text = getValText()
				callback(default)
			end
		end
		updateGroupSeparators(parent)

		local dropdownFuncs = {}
		function dropdownFuncs:Refresh(newValues)
			if newValues then values = newValues end
		end
		return dropdownFuncs
	end

	function Elements:Section(options)
		endGroup()
		elementCount = elementCount + 1
		local head = options.Head or "Section"
		local body = options.body or options.Body or ""
		local headSize = options.HeadSize or window.HeadFontSize
		local bodySize = options.BodySize or window.BodyFontSize
		local icon = options.Icon

		local frame = Instance.new("Frame", page)
		frame.LayoutOrder = elementCount
		frame.Size = UDim2.new(1, 0, 0, 40)
		frame.BackgroundTransparency = 1

		local headLabel = Instance.new("TextLabel", frame)
		headLabel.Text = head
		headLabel.Size = UDim2.new(1, 0, 0, 20)
		headLabel.Font = Enum.Font.GothamBold
		headLabel.TextSize = headSize
		headLabel.TextXAlignment = Enum.TextXAlignment.Left
		headLabel.BackgroundTransparency = 1

		local padding = Instance.new("UIPadding", headLabel)
		if icon then
			window:CreateIcon(frame, icon, UDim2.new(0, 0, 0, 10))
			padding.PaddingLeft = UDim.new(0, 25)
		end

		local bodyLabel = Instance.new("TextLabel", frame)
		bodyLabel.Text = body
		bodyLabel.Size = UDim2.new(1, 0, 0, 15)
		bodyLabel.Position = UDim2.fromOffset(0, 20)
		bodyLabel.Font = Enum.Font.Gotham
		bodyLabel.TextSize = bodySize
		bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
		bodyLabel.BackgroundTransparency = 1

		window:AddThemeObject(headLabel, {TextColor3 = "Text"})
		window:AddThemeObject(bodyLabel, {TextColor3 = "TextSub"})

		local sectionObject = {}
		function sectionObject:SetText(newOptions)
			if type(newOptions) ~= "table" then return end
			if newOptions.Head then
				headLabel.Text = newOptions.Head
			end
			if newOptions.Body then
				bodyLabel.Text = newOptions.Body
			end
		end
		
		return sectionObject
	end

	function Elements:Popup(options)
		local text = options.Title or "Popup Button"
		local msg = options.Message or "Are you sure?"
		local onConfirm = options.onConfirm or function() end
		local onCancel = options.onCancel or function() end
		local icon = options.Icon

		local parent = getGroup()
		local btn = Instance.new("TextButton", parent)
		btn.Size = UDim2.new(1, 0, 0, 42)
		btn.Text = text
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 15
		
		local padding = Instance.new("UIPadding", btn)
		padding.PaddingLeft = UDim.new(0, 0) -- Default centered? No, usually buttons are centered but here let's see
		if icon then
			window:CreateIcon(btn, icon, UDim2.new(0, 12, 0.5, 0))
			-- Adjust text alignment if needed, but standard button usually centered. 
			-- If left aligned:
			btn.TextXAlignment = Enum.TextXAlignment.Left
			padding.PaddingLeft = UDim.new(0, 40)
		else
			btn.TextXAlignment = Enum.TextXAlignment.Center
		end
		
		local separator = Instance.new("Frame", btn)
		separator.Name = "Separator"
		separator.Size = UDim2.new(1, 0, 0, 1)
		separator.Position = UDim2.new(0, 0, 1, -1)
		separator.BorderSizePixel = 0
		separator.BackgroundTransparency = 0.8
		window:AddThemeObject(separator, {BackgroundColor3 = "Stroke"})

		btn.BackgroundTransparency = 1
		window:AddThemeObject(btn, {
			TextColor3 = "Text"
		})
		
		btn.MouseButton1Click:Connect(function()
			window:ShowPopup(text, msg, onConfirm, onCancel)
		end)
		updateGroupSeparators(parent)
	end

	function Elements:Keybind(options)
		local text = options.Title or "Keybind"
		local default = options.Default or Enum.KeyCode.RightControl
		local callback = options.Callback or function() end
		local changedCallback = options.ChangedCallback or function() end
		local icon = options.Icon
		local flag = options.Flag

		if flag then
			if window.Flags[flag] ~= nil then
				default = window.Flags[flag]
			else
				window.Flags[flag] = default
			end
		end

		local parent = getGroup()
		local frame = Instance.new("Frame", parent)
		frame.Size = UDim2.new(1, 0, 0, 42)
		frame.BackgroundTransparency = 0

		local label = Instance.new("TextLabel", frame)
		label.Text = text
		label.Size = UDim2.new(1, -100, 1, 0)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 15
		label.TextColor3 = Color3.fromRGB(40, 40, 40)

		local padding = Instance.new("UIPadding", label)
		padding.PaddingLeft = UDim.new(0, 15)
		if icon then
			window:CreateIcon(frame, icon, UDim2.new(0, 12, 0.5, 0))
			padding.PaddingLeft = UDim.new(0, 40)
		end

		local btn = Instance.new("TextButton", frame)
		btn.Size = UDim2.new(0, 100, 0, 28)
		btn.Position = UDim2.new(1, -6, 0.5, 0)
		btn.AnchorPoint = Vector2.new(1, 0.5)
		btn.Text = default.Name
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		local stroke = Instance.new("UIStroke", btn)

		local key = default
		local listening = false

		local separator = Instance.new("Frame", frame)
		separator.Name = "Separator"
		separator.Size = UDim2.new(1, 0, 0, 1)
		separator.Position = UDim2.new(0, 0, 1, -1)
		separator.BorderSizePixel = 0
		separator.BackgroundTransparency = 0.8
		window:AddThemeObject(separator, {BackgroundColor3 = "Stroke"})

		frame.BackgroundTransparency = 1
		window:AddThemeObject(label, {TextColor3 = "Text"})
		window:AddThemeObject(btn, {BackgroundColor3 = "Sidebar", TextColor3 = "TextSub"})
		window:AddThemeObject(stroke, {Color = "Stroke"})

		btn.MouseButton1Click:Connect(function()
			listening = true
			btn.Text = "..."
			btn.TextColor3 = window.CurrentTheme.Accent
			stroke.Color = window.CurrentTheme.Accent
		end)

		table.insert(window.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					key = input.KeyCode
					btn.Text = key.Name
					btn.TextColor3 = window.CurrentTheme.TextSub
					stroke.Color = window.CurrentTheme.Stroke
					listening = false
					if flag then window.Flags[flag] = key end
					changedCallback(key)
				end
			elseif not gameProcessed and input.KeyCode == key then
				callback()
			end
		end))

		if flag then
			window.ConfigUpdates[flag] = function(newVal)
				key = newVal
				btn.Text = key.Name
				changedCallback(key)
			end
		end
		updateGroupSeparators(parent)
	end

	function Elements:Input(options)
		local text = options.Title or "Input"
		local placeholder = options.Placeholder or "Type here..."
		local default = options.Default or ""
		local callback = options.Callback or function() end
		local icon = options.Icon
		local flag = options.Flag

		if flag then
			if window.Flags[flag] ~= nil then
				default = window.Flags[flag]
			else
				window.Flags[flag] = default
			end
		end

		local parent = getGroup()
		local frame = Instance.new("Frame", parent)
		frame.Size = UDim2.new(1, 0, 0, 42)
		frame.BackgroundTransparency = 0

		local label = Instance.new("TextLabel", frame)
		label.Text = text
		label.Size = UDim2.new(0.4, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 15

		local padding = Instance.new("UIPadding", label)
		padding.PaddingLeft = UDim.new(0, 15)
		if icon then
			window:CreateIcon(frame, icon, UDim2.new(0, 12, 0.5, 0))
			padding.PaddingLeft = UDim.new(0, 40)
		end

		local input = Instance.new("TextBox", frame)
		input.Size = UDim2.new(0.6, 0, 1, 0)
		input.Position = UDim2.new(0.4, 0, 0, 0)
		input.Size = UDim2.new(0.6, 0, 0, 30)
		input.Position = UDim2.new(0.4, 0, 0.5, 0)
		input.AnchorPoint = Vector2.new(0, 0.5)
		input.Text = default
		input.PlaceholderText = placeholder
		input.TextXAlignment = Enum.TextXAlignment.Right
		input.Font = Enum.Font.Gotham
		input.TextSize = 14
		input.BackgroundTransparency = 1
		
		local inputPadding = Instance.new("UIPadding", input)
		inputPadding.PaddingRight = UDim.new(0, 15)

		local separator = Instance.new("Frame", frame)
		separator.Name = "Separator"
		separator.Size = UDim2.new(1, 0, 0, 1)
		separator.Position = UDim2.new(0, 0, 1, -1)
		separator.BorderSizePixel = 0
		separator.BackgroundTransparency = 0.8
		window:AddThemeObject(separator, {BackgroundColor3 = "Stroke"})

		frame.BackgroundTransparency = 1
		window:AddThemeObject(label, {TextColor3 = "Text"})
		window:AddThemeObject(input, {TextColor3 = "TextSub", PlaceholderColor3 = "TextSub"})

		input.FocusLost:Connect(function()
			if flag then window.Flags[flag] = input.Text end
			callback(input.Text)
		end)

		if flag then
			window.ConfigUpdates[flag] = function(newVal)
				input.Text = tostring(newVal)
				callback(newVal)
			end
		end
		updateGroupSeparators(parent)
	end

	function Elements:Space()
		endGroup()
	end

	return Elements
end

function Library:SelectTab(name)
	local btn = self.Sidebar:FindFirstChild(name)
	if btn then
		for _, connection in pairs(getconnections(btn.MouseButton1Click)) do
			connection:Fire()
		end
	end
end

return Library