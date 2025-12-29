local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
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
	local position = options.Position or UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
	local toggleKey = options.ToggleKey or Enum.KeyCode.RightControl
	
	-- Root
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "MacFinderLib"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.ScreenGui.Parent = playerGui

	self.IsMinimized = false
	self.OriginalSize = size

	-- Config System
	self.Flags = {}
	self.ConfigUpdates = {}
	
	function self:SaveConfig(name)
		local json = HttpService:JSONEncode(self.Flags)
		writefile(name .. ".json", json)
	end
	
	function self:LoadConfig(name)
		if isfile(name .. ".json") then
			local json = readfile(name .. ".json")
			local data = HttpService:JSONDecode(json)
			for k, v in pairs(data) do
				self.Flags[k] = v
				if self.ConfigUpdates[k] then
					self.ConfigUpdates[k](v)
				end
			end
		end
	end

	-- Theme System
	self.Themes = {
		Light = {
			Main = Color3.fromRGB(242, 242, 242),
			Sidebar = Color3.fromRGB(230, 230, 230),
			Text = Color3.fromRGB(40, 40, 40),
			TextSub = Color3.fromRGB(80, 80, 80),
			ElementBG = Color3.fromRGB(255, 255, 255),
			Accent = Color3.fromRGB(0, 122, 255),
			Stroke = Color3.fromRGB(170, 170, 170),
			TextBtn = Color3.fromRGB(255, 255, 255),
			ToggleInactive = Color3.fromRGB(200, 200, 200),
			ScrollBar = Color3.fromRGB(120, 120, 120)
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
			ScrollBar = Color3.fromRGB(120, 120, 120)
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
			ScrollBar = Color3.fromRGB(140, 120, 160)
		}
	}
	self.ThemeObjects = {}
	self.CurrentTheme = self.Themes[theme] or self.Themes.Light

	-- Keybind System
	self.ToggleKey = toggleKey
	
	-- Main Window 
	self.Main = Instance.new("CanvasGroup")
	self.Main.Name = "Main"
	self.Main.Size = self.OriginalSize
	self.Main.Position = position
	self.Main.AnchorPoint = Vector2.new(0, 0)
	self.Main.ClipsDescendants = true
	self.Main.Parent = self.ScreenGui
	
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 14) -- เพิ่มความมน
	mainCorner.Parent = self.Main

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Transparency = 0.5
	mainStroke.Parent = self.Main

	-- Shadow (Floating Effect)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.AnchorPoint = Vector2.new(0, 0)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://6014261993"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.4
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceScale = 1
	shadow.ZIndex = self.Main.ZIndex - 1
	shadow.Parent = self.ScreenGui

	-- Header Area (Drag Zone)
	self.Header = Instance.new("Frame")
	self.Header.Name = "Header"
	self.Header.Size = UDim2.new(1, 0, 0, 55)
	self.Header.BackgroundTransparency = 1
	self.Header.ZIndex = 2
	self.Header.Parent = self.Main

	-- Sidebar Separator (Line that appears when scrolling)
	local sbSep = Instance.new("Frame")
	sbSep.Name = "SidebarSeparator"
	sbSep.Size = UDim2.new(0, 180, 0, 1)
	sbSep.Position = UDim2.new(0, 0, 0, 55)
	sbSep.BackgroundTransparency = 1
	sbSep.BorderSizePixel = 0
	sbSep.ZIndex = 5
	sbSep.Parent = self.Main

	-- Sidebar Header (Static background for top left)
	local sbHeader = Instance.new("Frame")
	sbHeader.Name = "SidebarHeader"
	sbHeader.Size = UDim2.new(0, 180, 0, 55)
	sbHeader.Position = UDim2.new(0, 0, 0, 0)
	sbHeader.BackgroundTransparency = 0.2
	sbHeader.BorderSizePixel = 0
	sbHeader.Parent = self.Main

	-- Sidebar
	self.Sidebar = Instance.new("ScrollingFrame")
	self.Sidebar.Name = "Sidebar"
	self.Sidebar.Size = UDim2.new(0, 180, 1, -55)
	self.Sidebar.Position = UDim2.new(0, 0, 0, 55)
	self.Sidebar.BackgroundTransparency = 0.2
	self.Sidebar.BorderSizePixel = 0
	self.Sidebar.ScrollBarThickness = 3
	self.Sidebar.ScrollBarImageTransparency = 1 -- ซ่อนไว้ก่อน
	self.Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.Sidebar.ZIndex = 2
	self.Sidebar.Parent = self.Main
	

	local sbFade
	self.Sidebar:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		sbSep.BackgroundTransparency = (self.Sidebar.CanvasPosition.Y > 5) and 0 or 1
		if sbFade then sbFade:Cancel() end
		self.Sidebar.ScrollBarImageTransparency = 0.7
		sbFade = TweenService:Create(self.Sidebar, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.5), {ScrollBarImageTransparency = 1})
		sbFade:Play()
	end)

	local sLayout = Instance.new("UIListLayout", self.Sidebar)
	sLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sLayout.Padding = UDim.new(0, 5)
	sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
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
	function self:CreateIcon(parent, iconName, pos)
		if not iconName then return end
		local info = Lucide.GetAsset(iconName)
		if not info then return end

		local icon = Instance.new("ImageLabel", parent)
		icon.Name = "Icon"
		icon.Size = UDim2.fromOffset(20, 20)
		icon.Position = pos or UDim2.fromScale(0, 0.5)
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.BackgroundTransparency = 1
		icon.Image = info.Url
		icon.ImageRectSize = info.ImageRectSize
		icon.ImageRectOffset = info.ImageRectOffset
		self:AddThemeObject(icon, {ImageColor3 = "Text"})
		return icon
	end

	-- Traffic Lights 
	local traffic = Instance.new("Frame")
	traffic.Size = UDim2.fromOffset(90, 55)
	traffic.Position = UDim2.fromOffset(18, 0)
	traffic.BackgroundTransparency = 1
	traffic.ZIndex = 10
	traffic.Parent = self.Main
	
	local tLayout = Instance.new("UIListLayout", traffic)
	tLayout.FillDirection = Enum.FillDirection.Horizontal
	tLayout.Padding = UDim.new(0, 10) -- ระยะห่างระหว่างปุ่ม
	tLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	-- Popup System
	function self:ShowPopup(titleText, msgText, onConfirm)
		local overlay = Instance.new("Frame", self.ScreenGui)
		overlay.Name = "PopupOverlay"
		overlay.Size = UDim2.fromScale(1, 1)
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

		local yes = createBtn("Confirm", Color3.fromRGB(255, 59, 48), onConfirm)
		yes.Position = UDim2.new(0.5, 5, 1, -40)
		
		local no = createBtn("Cancel", Color3.fromRGB(180, 180, 180), nil)
		no.Position = UDim2.new(0.1, 0, 1, -40)

		TweenService:Create(box, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(280, 140)}):Play()
	end

	-- Selection Popup System (Dropdown)
	function self:ShowSelection(titleText, options, callback)
		local overlay = Instance.new("Frame", self.ScreenGui)
		overlay.Name = "SelectionOverlay"
		overlay.Size = UDim2.fromScale(1, 1)
		overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		overlay.BackgroundTransparency = 1
		overlay.ZIndex = 110
		TweenService:Create(overlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()

		local box = Instance.new("Frame", overlay)
		box.Size = UDim2.fromOffset(250, 0)
		box.Position = UDim2.fromScale(0.5, 0.5)
		box.AnchorPoint = Vector2.new(0.5, 0.5)
		box.ClipsDescendants = true
		Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)
		
		self:AddThemeObject(box, {BackgroundColor3 = "Main"})

		local list = Instance.new("ScrollingFrame", box)
		list.Size = UDim2.new(1, 0, 1, 0)
		list.BackgroundTransparency = 1
		list.ScrollBarThickness = 2
		list.AutomaticCanvasSize = Enum.AutomaticSize.Y
		list.CanvasSize = UDim2.new(0, 0, 0, 0)
		
		local layout = Instance.new("UIListLayout", list)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		
		local function close()
			TweenService:Create(overlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
			TweenService:Create(box, TweenInfo.new(0.2), {Size = UDim2.fromOffset(250, 0)}):Play()
			task.wait(0.2)
			overlay:Destroy()
		end

		for i, v in ipairs(options) do
			local btn = Instance.new("TextButton", list)
			btn.Size = UDim2.new(1, 0, 0, 40)
			btn.BackgroundTransparency = 1
			btn.Text = tostring(v)
			btn.Font = Enum.Font.GothamMedium
			btn.TextSize = 14
			btn.LayoutOrder = i
			
			self:AddThemeObject(btn, {TextColor3 = "Text"})

			btn.MouseButton1Click:Connect(function()
				callback(v)
				close()
			end)
		end

		TweenService:Create(box, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(250, math.min(300, #options * 40))}):Play()
	end

	-- Notification System
	local notifyHolder = Instance.new("Frame", self.ScreenGui)
	notifyHolder.Name = "Notifications"
	notifyHolder.Size = UDim2.new(0, 250, 1, -20)
	notifyHolder.Position = UDim2.new(1, -270, 0, 10)
	notifyHolder.BackgroundTransparency = 1
	notifyHolder.ZIndex = 100
	
	local nLayout = Instance.new("UIListLayout", notifyHolder)
	nLayout.Padding = UDim.new(0, 10)
	nLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	nLayout.SortOrder = Enum.SortOrder.LayoutOrder

	function self:Notify(titleText, descText, duration)
		local frame = Instance.new("Frame", notifyHolder)
		frame.Size = UDim2.new(1, 0, 0, 60)
		frame.BackgroundTransparency = 0.1
		frame.Position = UDim2.fromOffset(300, 0) -- Start off screen
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
		local stroke = Instance.new("UIStroke", frame)
		
		local tLabel = Instance.new("TextLabel", frame)
		tLabel.Text = titleText
		tLabel.Size = UDim2.new(1, -20, 0, 25)
		tLabel.Position = UDim2.fromOffset(10, 5)
		tLabel.Font = Enum.Font.GothamBold
		tLabel.TextSize = 14
		tLabel.TextXAlignment = Enum.TextXAlignment.Left
		tLabel.BackgroundTransparency = 1
		
		local dLabel = Instance.new("TextLabel", frame)
		dLabel.Text = descText
		dLabel.Size = UDim2.new(1, -20, 0, 25)
		dLabel.Position = UDim2.fromOffset(10, 28)
		dLabel.Font = Enum.Font.Gotham
		dLabel.TextSize = 13
		dLabel.TextXAlignment = Enum.TextXAlignment.Left
		dLabel.BackgroundTransparency = 1

		self:AddThemeObject(frame, {BackgroundColor3 = "ElementBG"})
		self:AddThemeObject(stroke, {Color = "Stroke"})
		self:AddThemeObject(tLabel, {TextColor3 = "Text"})
		self:AddThemeObject(dLabel, {TextColor3 = "TextSub"})

		TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.fromOffset(0, 0)}):Play()
		
		task.delay(duration or 3, function()
			TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}):Play()
			TweenService:Create(tLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {TextTransparency = 1}):Play()
			TweenService:Create(dLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {TextTransparency = 1}):Play()
			TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Transparency = 1}):Play()
			task.wait(0.5)
			frame:Destroy()
		end)
	end

	local function makeDot(color, action)
		local btn = Instance.new("TextButton", traffic)
		btn.Size = UDim2.fromOffset(13, 13) -- ขนาดปุ่มใหญ่ขึ้น
		btn.BackgroundColor3 = color
		btn.Text = ""
		btn.AutoButtonColor = false
		Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
		btn.MouseButton1Click:Connect(action)
	end

	makeDot(Color3.fromRGB(255, 95, 87), function() 
		self:ShowPopup("Close Window", "Are you sure you want to close?", function() self.ScreenGui:Destroy() end)
	end)
	makeDot(Color3.fromRGB(255, 189, 46), function()
		self.IsMinimized = not self.IsMinimized
		local targetSize = self.IsMinimized and UDim2.fromOffset(180, 55) or self.OriginalSize
		TweenService:Create(self.Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
	end)
	makeDot(Color3.fromRGB(40, 201, 64), function() end)

	-- Dragging Logic
	local dragging, dragStart, startPos
	self.Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = self.Main.Position
		end
	end)

	-- Resizing Logic (Fixed)
	local resizer = Instance.new("ImageLabel", self.Main)
	resizer.Name = "Resizer"
	resizer.Size = UDim2.fromOffset(16, 16)
	resizer.Position = UDim2.new(1, -16, 1, -16)
	resizer.BackgroundTransparency = 1
	resizer.Image = "rbxassetid://12752150117"
	resizer.ZIndex = 15

	local resizing = false
	local rStartSize, rStartPos
	resizer.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			rStartPos = input.Position
			rStartSize = self.Main.AbsoluteSize
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then resizing = false end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		elseif resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - rStartPos
			local newSize = UDim2.fromOffset(math.max(450, rStartSize.X + delta.X), math.max(300, rStartSize.Y + delta.Y))
			self.Main.Size = newSize
			self.OriginalSize = newSize
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			resizing = false
		end
	end)

	-- Sync Shadow Position & Size
	local function syncShadow()
		shadow.Position = self.Main.Position + UDim2.fromOffset(-20, -16)
		shadow.Size = self.Main.Size + UDim2.fromOffset(40, 40)
	end
	self.Main:GetPropertyChangedSignal("Position"):Connect(syncShadow)
	self.Main:GetPropertyChangedSignal("Size"):Connect(syncShadow)
	syncShadow()

	-- Apply Initial Theme
	self:AddThemeObject(self.Main, {BackgroundColor3 = "Main"})
	self:AddThemeObject(mainStroke, {Color = "Stroke"})
	self:AddThemeObject(sbSep, {BackgroundColor3 = "Stroke"})
	self:AddThemeObject(sbHeader, {BackgroundColor3 = "Sidebar"})
	self:AddThemeObject(self.Sidebar, {BackgroundColor3 = "Sidebar", ScrollBarImageColor3 = "ScrollBar"})
	self:AddThemeObject(resizer, {ImageColor3 = "TextSub"})

	-- Global Keybind Listener
	UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == self.ToggleKey then
			self.ScreenGui.Enabled = not self.ScreenGui.Enabled
		end
	end)

	self.Tabs = {}
	self.TabCount = 0
	self.ActiveTab = nil
	self.ActivePage = nil
	return self
end

function Library:CreateTab(name, subtitle, iconName)
	local window = self
	window.TabCount = window.TabCount + 1
	local tabBtn = Instance.new("TextButton", self.Sidebar)
	tabBtn.LayoutOrder = window.TabCount
	tabBtn.Name = name
	tabBtn.Size = UDim2.new(0.92, 0, 0, 32)
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = name
	tabBtn.Font = Enum.Font.GothamMedium
	tabBtn.TextSize = 15
	tabBtn.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

	local padding = Instance.new("UIPadding", tabBtn)
	if iconName then
		window:CreateIcon(tabBtn, iconName, UDim2.new(0, 10, 0.5, 0))
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
	
	local pLayout = Instance.new("UIListLayout", page)
	pLayout.Padding = UDim.new(0, 15) -- ระยะห่างระหว่าง Group
	pLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	local pPadding = Instance.new("UIPadding", page)
	pPadding.PaddingLeft = UDim.new(0, 25) -- เพิ่มระยะห่าง
	pPadding.PaddingRight = UDim.new(0, 20) -- ลดขวาลงนิดนึงเพราะ Scrollbar ลอยเข้ามา
	pPadding.PaddingTop = UDim.new(0, 20)
	pPadding.PaddingBottom = UDim.new(0, 10)
	
	-- Tab Header (Fixed at top)
	local headFrame = Instance.new("Frame", container)
	headFrame.Name = "Header"
	headFrame.Size = UDim2.new(1, 0, 0, 55)
	headFrame.BackgroundTransparency = 1
	Instance.new("UIPadding", headFrame).PaddingLeft = UDim.new(0, 25)
	
	local hLayout = Instance.new("UIListLayout", headFrame)
	hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	hLayout.Padding = UDim.new(0, 0)

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
	local cFade
	page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		-- Show divider when scrolling
		divider.BackgroundTransparency = (page.CanvasPosition.Y > 5) and 0 or 1

		if cFade then cFade:Cancel() end
		page.ScrollBarImageTransparency = 0.7
		cFade = TweenService:Create(page, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.5), {ScrollBarImageTransparency = 1})
		cFade:Play()
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
		for _, c in ipairs(group:GetChildren()) do
			if c:IsA("Frame") or c:IsA("TextButton") then
				table.insert(frames, c)
			end
		end
		table.sort(frames, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
		
		for i, f in ipairs(frames) do
			local sep = f:FindFirstChild("Separator")
			if sep then
				sep.Visible = (i < #frames)
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

	local elementCount = 0

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
			window:CreateIcon(btn, icon, UDim2.new(0, 12, 0.5, 0))
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

		local sep = Instance.new("Frame", frame)
		sep.Name = "Separator"
		sep.Size = UDim2.new(1, 0, 0, 1)
		sep.Position = UDim2.new(0, 0, 1, -1)
		sep.BorderSizePixel = 0
		window:AddThemeObject(sep, {BackgroundColor3 = "Stroke"})

		window:AddThemeObject(btn, {
			TextColor3 = "Text"
		})

		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local x = input.Position.X - btn.AbsolutePosition.X
				local y = input.Position.Y - btn.AbsolutePosition.Y
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
		
		local sep = Instance.new("Frame", frame)
		sep.Name = "Separator"
		sep.Size = UDim2.new(1, 0, 0, 1)
		sep.Position = UDim2.new(0, 0, 1, -1)
		sep.BorderSizePixel = 0
		window:AddThemeObject(sep, {BackgroundColor3 = "Stroke"})

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

		local bar = Instance.new("Frame", sliderContainer)
		bar.Size = UDim2.new(1, -30, 0, 4) -- เพิ่มระยะห่างขอบไม่ให้หลุด
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

		local sep = Instance.new("Frame", frame)
		sep.Name = "Separator"
		sep.Size = UDim2.new(1, 0, 0, 1)
		sep.Position = UDim2.new(0, 0, 1, -1)
		sep.BorderSizePixel = 0
		window:AddThemeObject(sep, {BackgroundColor3 = "Stroke"})

		frame.BackgroundTransparency = 1
		window:AddThemeObject(label, {TextColor3 = "Text"})
		window:AddThemeObject(bar, {BackgroundColor3 = "ToggleInactive"})
		window:AddThemeObject(fill, {BackgroundColor3 = "Accent"})
		window:AddThemeObject(knobVisual, {BackgroundColor3 = "ElementBG"})
		window:AddThemeObject(knobStroke, {Color = "Stroke"})

		local dragging = false
		local function update()
			local mousePos = UserInputService:GetMouseLocation().X
			local barPos = bar.AbsolutePosition.X
			local barSize = bar.AbsoluteSize.X
			local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
			
			fill.Size = UDim2.fromScale(percent, 1)
			knob.Position = UDim2.fromScale(percent, 0.5)
			local value = math.floor(min + (max - min) * percent)
			label.Text = text .. ": " .. value
			if flag then window.Flags[flag] = value end
			callback(value)
		end

		knob.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update() end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)

		if flag then
			window.ConfigUpdates[flag] = function(newVal)
				local value = math.clamp(newVal, min, max)
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
		local default = options.Value or values[1]
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

		-- Value Button (Click to open popup)
		local valueBtn = Instance.new("TextButton", frame)
		valueBtn.Size = UDim2.new(0, 200, 0, 28)
		valueBtn.Position = UDim2.new(1, -10, 0.5, 0)
		valueBtn.AnchorPoint = Vector2.new(1, 0.5)
		valueBtn.BackgroundTransparency = 0.9
		valueBtn.Text = "  " .. tostring(default)
		valueBtn.TextXAlignment = Enum.TextXAlignment.Left
		valueBtn.Font = Enum.Font.Gotham
		valueBtn.TextSize = 14
		Instance.new("UICorner", valueBtn).CornerRadius = UDim.new(0, 6)
		Instance.new("UIPadding", valueBtn).PaddingRight = UDim.new(0, 35) -- เว้นที่ให้ปุ่ม Selector ด้านใน

		-- Selector Box (Arrows)
		local arrowBox = Instance.new("Frame", valueBtn) -- ย้ายเข้าไปข้างใน valueBtn
		arrowBox.Size = UDim2.new(0, 20, 0, 20)
		arrowBox.Position = UDim2.new(1.19, 0, 0.5, 0)
		arrowBox.AnchorPoint = Vector2.new(1, 0.5)
		arrowBox.BackgroundColor3 = window.CurrentTheme.Accent -- สีฟ้า
		Instance.new("UICorner", arrowBox).CornerRadius = UDim.new(0, 4)

		local upBtn = Instance.new("TextButton", arrowBox)
		upBtn.Size = UDim2.new(1, 0, 0.5, 0)
		upBtn.BackgroundTransparency = 1
		upBtn.Text = "▲"
		upBtn.TextSize = 10
		upBtn.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว

		local downBtn = Instance.new("TextButton", arrowBox)
		downBtn.Size = UDim2.new(1, 0, 0.5, 0)
		downBtn.Position = UDim2.new(0, 0, 0.5, 0)
		downBtn.BackgroundTransparency = 1
		downBtn.Text = "▼"
		downBtn.TextSize = 10
		downBtn.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว

		local sep = Instance.new("Frame", frame)
		sep.Name = "Separator"
		sep.Size = UDim2.new(1, 0, 0, 1)
		sep.Position = UDim2.new(0, 0, 1, -1)
		sep.BorderSizePixel = 0
		window:AddThemeObject(sep, {BackgroundColor3 = "Stroke"})

		frame.BackgroundTransparency = 1
		window:AddThemeObject(label, {TextColor3 = "Text"})
		window:AddThemeObject(valueBtn, {TextColor3 = "TextSub", BackgroundColor3 = "Text"})
		window:AddThemeObject(arrowBox, {BackgroundColor3 = "Accent"})
		window:AddThemeObject(upBtn, {TextColor3 = "TextBtn"})
		window:AddThemeObject(downBtn, {TextColor3 = "TextBtn"})

		local function updateValue(v)
			valueBtn.Text = "  " .. tostring(v)
			if flag then window.Flags[flag] = v end
			callback(v)
		end

		-- Popup Logic
		valueBtn.MouseButton1Click:Connect(function()
        if window.DropdownOpen then return end
        window.DropdownOpen = true

        local overlay = Instance.new("TextButton", window.ScreenGui)
        overlay.Name = "DropdownOverlay"
        overlay.Size = UDim2.fromScale(1, 1)
        overlay.BackgroundTransparency = 1
        overlay.Text = ""
        overlay.AutoButtonColor = false
        overlay.Selectable = false
        overlay.ZIndex = 200

        local popup = Instance.new("Frame", window.ScreenGui)
        popup.Name = "DropdownPopup"
        popup.Size = UDim2.fromOffset(valueBtn.AbsoluteSize.X, 0)
        popup.Position = UDim2.fromOffset(
            valueBtn.AbsolutePosition.X,
            valueBtn.AbsolutePosition.Y + valueBtn.AbsoluteSize.Y + 5
        )
        popup.BackgroundColor3 = window.CurrentTheme.ElementBG
        popup.ZIndex = 201
        popup.ClipsDescendants = true

        local popupCorner = Instance.new("UICorner", popup)
        popupCorner.CornerRadius = UDim.new(0, 10)

        local stroke = Instance.new("UIStroke", popup)
        stroke.Color = window.CurrentTheme.Stroke
        stroke.Transparency = 0.6

        local padding = Instance.new("UIPadding", popup)
        padding.PaddingTop = UDim.new(0, 1)
        padding.PaddingBottom = UDim.new(0, 1)
        padding.PaddingLeft = UDim.new(0, 1)
        padding.PaddingRight = UDim.new(0, 1)

        local layout = Instance.new("UIListLayout", popup)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local function close()
            if overlay then overlay:Destroy() end
            if popup then popup:Destroy() end
            window.DropdownOpen = false
        end

        overlay.MouseButton1Click:Connect(close)

        local currentVal = valueBtn.Text:sub(3)

        for i, v in ipairs(values) do
            local isSelected = (tostring(v) == currentVal)

            local btn = Instance.new("TextButton", popup)
            btn.Size = UDim2.new(1, 0, 0, 32)
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
            btnCorner.CornerRadius = UDim.new(0, 8)

            local check = Instance.new("TextLabel", btn)
            check.Size = UDim2.new(0, 30, 1, 0)
            check.BackgroundTransparency = 1
            check.Text = "✔"
            check.Font = Enum.Font.GothamBold
            check.TextSize = 14
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

            if i < #values then
                local sep = Instance.new("Frame", btn)
                sep.Size = UDim2.new(1, 0, 0, 1)
                sep.Position = UDim2.new(0, 0, 1, -1)
                sep.BorderSizePixel = 0
                sep.BackgroundColor3 = window.CurrentTheme.Stroke
                sep.BackgroundTransparency = 0.7
            end

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
                close()
            end)
        end

        popup.Size = UDim2.fromOffset(valueBtn.AbsoluteSize.X, #values * 32 + 2)
    end)

		-- Cycle Logic
		local function cycle(dir)
			local current = valueBtn.Text:sub(3)
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

		upBtn.MouseButton1Click:Connect(function()
			cycle(-1)
		end)
		downBtn.MouseButton1Click:Connect(function()
			cycle(1)
		end)

		if flag then
			window.ConfigUpdates[flag] = function(newVal)
				updateValue(newVal)
			end
		end
		updateGroupSeparators(parent)
	end

	function Elements:Section(options)
		endGroup()
		elementCount = elementCount + 1
		local head = options.Head or "Section"
		local body = options.body or options.Body or ""
		local headSize = options.HeadSize or 14
		local bodySize = options.BodySize or 12
		local icon = options.Icon

		local frame = Instance.new("Frame", page)
		frame.LayoutOrder = elementCount
		frame.Size = UDim2.new(1, 0, 0, 40)
		frame.BackgroundTransparency = 1
		
		local hLabel = Instance.new("TextLabel", frame)
		hLabel.Text = head
		hLabel.Size = UDim2.new(1, 0, 0, 20)
		hLabel.Font = Enum.Font.GothamBold
		hLabel.TextSize = headSize
		hLabel.TextXAlignment = Enum.TextXAlignment.Left
		hLabel.BackgroundTransparency = 1
		
		local padding = Instance.new("UIPadding", hLabel)
		if icon then
			window:CreateIcon(frame, icon, UDim2.new(0, 0, 0, 10))
			padding.PaddingLeft = UDim.new(0, 25)
		end

		local bLabel = Instance.new("TextLabel", frame)
		bLabel.Text = body
		bLabel.Size = UDim2.new(1, 0, 0, 15)
		bLabel.Position = UDim2.fromOffset(0, 20)
		bLabel.Font = Enum.Font.Gotham
		bLabel.TextSize = bodySize
		bLabel.TextXAlignment = Enum.TextXAlignment.Left
		bLabel.BackgroundTransparency = 1

		window:AddThemeObject(hLabel, {TextColor3 = "Text"})
		window:AddThemeObject(bLabel, {TextColor3 = "TextSub"})
	end

	function Elements:Popup(options)
		local text = options.Title or "Popup Button"
		local msg = options.Message or "Are you sure?"
		local callback = options.Callback or function() end
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
		end
		
		local sep = Instance.new("Frame", btn)
		sep.Name = "Separator"
		sep.Size = UDim2.new(1, 0, 0, 1)
		sep.Position = UDim2.new(0, 0, 1, -1)
		sep.BorderSizePixel = 0
		window:AddThemeObject(sep, {BackgroundColor3 = "Stroke"})

		btn.BackgroundTransparency = 1
		window:AddThemeObject(btn, {
			TextColor3 = "Text"
		})
		
		btn.MouseButton1Click:Connect(function()
			window:ShowPopup(text, msg, callback)
		end)
		updateGroupSeparators(parent)
	end

	function Elements:Keybind(options)
		local text = options.Title or "Keybind"
		local default = options.Default or Enum.KeyCode.RightControl
		local callback = options.Callback or function() end
		local changedCallback = options.ChangedCallback or function() end
		local icon = options.Icon

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

		local sep = Instance.new("Frame", frame)
		sep.Name = "Separator"
		sep.Size = UDim2.new(1, 0, 0, 1)
		sep.Position = UDim2.new(0, 0, 1, -1)
		sep.BorderSizePixel = 0
		window:AddThemeObject(sep, {BackgroundColor3 = "Stroke"})

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

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					key = input.KeyCode
					btn.Text = key.Name
					btn.TextColor3 = window.CurrentTheme.TextSub
					stroke.Color = window.CurrentTheme.Stroke
					listening = false
					changedCallback(key)
				end
			elseif not gameProcessed and input.KeyCode == key then
				callback()
			end
		end)
		updateGroupSeparators(parent)
	end

	function Elements:Input(options)
		local text = options.Title or "Input"
		local placeholder = options.Placeholder or "Type here..."
		local callback = options.Callback or function() end
		local icon = options.Icon

		local parent = getGroup()
		local frame = Instance.new("Frame", parent)
		frame.Size = UDim2.new(1, 0, 0, 50)
		frame.BackgroundTransparency = 0

		local label = Instance.new("TextLabel", frame)
		label.Text = text
		label.Size = UDim2.new(1, 0, 0, 20)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 15

		local padding = Instance.new("UIPadding", label)
		padding.PaddingLeft = UDim.new(0, 15)
		if icon then
			window:CreateIcon(frame, icon, UDim2.new(0, 12, 0.5, -2)) -- Slightly adjusted for top label
			padding.PaddingLeft = UDim.new(0, 40)
		end

		local input = Instance.new("TextBox", frame)
		input.Size = UDim2.new(1, 0, 0, 30)
		input.Position = UDim2.fromOffset(0, 20)
		input.Text = ""
		input.PlaceholderText = placeholder
		input.TextXAlignment = Enum.TextXAlignment.Left
		input.Font = Enum.Font.Gotham
		input.TextSize = 14
		input.BackgroundTransparency = 1
		Instance.new("UIPadding", input).PaddingLeft = UDim.new(0, 10)

		local sep = Instance.new("Frame", frame)
		sep.Name = "Separator"
		sep.Size = UDim2.new(1, 0, 0, 1)
		sep.Position = UDim2.new(0, 0, 1, -1)
		sep.BorderSizePixel = 0
		window:AddThemeObject(sep, {BackgroundColor3 = "Stroke"})

		frame.BackgroundTransparency = 1
		window:AddThemeObject(label, {TextColor3 = "Text"})
		window:AddThemeObject(input, {TextColor3 = "TextSub"})

		input.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				callback(input.Text)
			end
		end)
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