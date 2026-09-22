# Replica Mac Ventura System Settings UI Library 🍎

A modern, sleek, and macOS-inspired User Interface library for Roblox scripts. Designed for developers who want a clean, professional look for their hubs with built-in configuration handling.

![Preview](assets/preview.png)

## ✨ Features

- **MacOS Aesthetic**: Authentic look with "traffic light" window controls, sidebar navigation, and smooth animations.
- **Fully Interactive**: Draggable, Resizable, and Minimizable window.
- **Theme System**: Built-in `Light`, `Dark`, `Purple` (+ `Green`, `Orange`, `Pink`, `Blue`, `Red`, `Neon`) themes with dynamic switching.
- **Genie Minimize**: iPhone-style shrink-and-fly animation into the Dock pill (green button, Dock click, or `ToggleKey` all use it).
- **SF-style Fonts**: iPhone-like typography via `BuilderSans` (auto-falls back to `Gotham`), customizable per weight.
- **Optional Glass Looks**: `Vibrancy` / `LiquidGlass` modes for translucent frosted panels (off by default).
- **Animated Tabs**: crossfading highlight, content fade-and-rise, hover glow, press scale, and an `OnTabChanged` event.
- **Configuration Manager**: Easy Save/Load system using `Flags`.
- **Rich Elements**:
  - Toggles (Switch style)
  - Sliders (Draggable with fill)
  - Dropdowns (Modern selection)
  - Keybinds
  - Text Inputs
  - Buttons with Ripple effects
- **Notification System**: Built-in toast notifications.
- **Lucide Icons**: Integrated support for Lucide icons.

## 📦 Getting Started

To use this library in your script, `loadstring` the source (replace the URL with your actual raw file link):

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/arsyny1x/replica-mac-ui/refs/heads/main/main.lua"))()
```

# 🛠️ Documentation

## 1. Create a Window
```lua
local Window = Library.CreateWindow({
	Title = "MacHub Premium",
	Folder = "MacHub Premium",
    AutoSaveSetting = true,
	Size = UDim2.fromOffset(550, 350),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Theme = "Light", -- Light, Dark, Purple, Green, Orange, Pink, Blue, Red, Neon
	ToggleKey = Enum.KeyCode.RightControl,
	-- Fonts (iPhone SF-style; BuilderSans with Gotham fallback)
	-- FontRegular / FontMedium / FontBold / FontHeavy (Enum.Font)
	-- HeadFontSize = 17, -- section headline size (default 17)
	-- BodyFontSize = 12, -- section description size (default 12)
	-- Glass looks (both off by default = classic opaque look)
	-- Vibrancy = false, -- translucent panels
	-- VibrancyAmount = 0.15, -- panel transparency when Vibrancy is on
	-- LiquidGlass = false, -- frosted-glass sheen + glowing edge + translucent groups
})
```

#### Window Effects & Helpers
```lua
Window:MinimizeToDock() -- fly the window into the Dock pill (iOS Genie style)
Window:RestoreFromDock() -- expand back from the Dock pill
Window:RefreshLayout() -- re-fit groups and redraw stuck content
Window.OnTabChanged = function(tabId, tabName) -- fires on every tab switch
    print("tab:", tabId, tabName)
end
print(Library.Version) -- e.g. "2.5.0"
```

#### Destroy Ui
```lua
Window.ScreenGui:Destroy() 
```

## 2. Create Profile
```lua
local Profile = Window:CreateProfileTab({
    Title = "Roblox ID",  
    --Name = "Roblox ID",    
    --Subtitle = "Level 999",    
    --Image = "rbxassetid://..."
})
```

## 3. Create a Tab
```lua
local MainTab = Window:CreateTab({
    Title = "Main",
    Subtitle = "Auto Farm & Stats",
    Icon = "lucide:a-arrow-up" -- Icon = "lucide:a-arrow-up" or Icon = "Solar:4-k-bold"
}) 
```

## 4. Add Elements

### Section
Used to group elements visually.
```lua
local MySection = MainTab:Section({ 
    Title = "Selection", 
    Subtitle = "Hello World",
    HeadSize = 17, -- headline font size (default = Window.HeadFontSize, 17)
    BodySize = 12, -- description font size (default = Window.BodyFontSize, 12)
})

-- Update New Text
MySection:SetText({ 
    Title = "Update Selection", 
    Subtitle = "The quick brown fox jumps over the lazy dog" 
})
```

### Button
```lua
MainTab:Button({
    Title = "Button",
    Icon = "lucide:a-arrow-up", -- Icon = "lucide:a-arrow-up" or Icon = "Solar:4-k-bold"
    Callback = function()
        print("Button Cllicked")
    end
})
```

### Toggle
Supports `Flag` for config saving.
Returns an object with `:OnChanged(callback)` and `:Set(value)`.
```lua
local MyToggle = MainTab:Toggle({
    Title = "Toggle",
    Flag = "Toggle",
    Icon = "lucide:a-arrow-up",
    Default = false,
    Callback = function(value)
        print("Auto Attack:", value)
    end
})

MyToggle:OnChanged(function(value)
    print("Toggle changed to:", value)
end)

-- Icon = "lucide:a-arrow-up" or Icon = "Solar:4-k-bold"
-- Programmatically set value
-- MyToggle:Set(true)
```

### Slider
Supports `Flag` for config saving.
Returns an object with `:Set(value)` / `:SetValue(value)`, `:Get()`, and `:OnChanged(callback)` — WindUI style. Knob + fill tween automatically when value is changed from script. Dragging is locked to the finger that grabbed it, so walking (joystick) or camera drags can't hijack the slider on mobile. The value popup is unclippable and follows the knob.
```lua
local MySlider = MainTab:Slider({
    Title = "Slider",
    Icon = "lucide:a-arrow-up",
    Min = 16,
    Max = 100,
    Default = 16,
    Flag = "Slider",
    Callback = function(value)
        print("Slider value:", value)
    end
})

-- Extra listener (does not replace Callback)
MySlider:OnChanged(function(value)
    print("Slider changed to:", value)
end)

-- Programmatically set value (knob moves automatically)
MySlider:Set(50)
MySlider:SetValue(80) -- alias, same as :Set()

-- Read current value
print(MySlider:Get())

-- Via Flag (also moves knob automatically)
Window.Switch.Slider = 30
print(Window.Flags.Slider)
```

### Dropdown
Supports `Flag` for config saving.
```lua
local DropDown = MainTab:Dropdown({
    Title = "Select Weapon",
    Flag = "WeaponSelector",
    Icon = "lucide:a-arrow-up",
    Multi = true, -- Multiple selection
    Values = {"Melee", "Sword", "Fruit"},
    Value = "Melee", -- Default
    Callback = function(value)
        print("Selected:", value)
    end
})

```
#### Refresh Dropdown
```lua
DropDown:Refresh({"Player1", "Player2", "Player3", "NewPlayer"})
```

### Selection Radio
```lua
MainTab:Radio({
    Title = "Select Mode",     
    Flag = "Select Mode",     
    Default = "Legit",         
    Options = {"Legit", "Rage", "Semi-Rage"}, 
    Callback = function(value)
        print("Selected Mode:", value)
    end
})
```

### Checkboxes
macOS-style inline checkbox group in a single row. Options sit side-by-side and wrap to the next line only when they overflow (row height grows automatically). White vector checkmark on blue.
Supports `Flag` for config saving.
Returns an object with `:OnChanged(callback)`, `:Get()`, and `:Set(value)`.
```lua
local Widgets = MainTab:Checkboxes({
    Title = "Show Widgets",
    Subtitle = "Choose surfaces",
    Icon = "lucide:a-arrow-up",
    Options = {"On Desktop", "In Stage Manager"},
    Value = {"On Desktop"}, -- default (table for Multi, string for Single)
    SelectionMode = "Multi", -- or "Single" (only one selected at a time)
    Flag = "Widgets",
    Callback = function(val)
        print(val)
    end
})

-- Multi returns a state table: {["On Desktop"] = true, ["In Stage Manager"] = false}
-- Single returns the selected option string (or nil)
Widgets:OnChanged(function(val)
    print("changed:", val)
end)

-- Programmatically set (list or map for Multi, string for Single)
Widgets:Set({"In Stage Manager"})

-- Read current value
print(Widgets:Get())
```

### Textinput
```lua
MainTab:Input({ 
    Title = "Text input",
	Icon = "lucide:a-arrow-up",
	Callback = function(v) 
		print("New input:", v)
    end
})
```

### Keybind
```lua
MainTab:Keybind({
    Title = "Toggle Menu",
    Icon = "lucide:a-arrow-up",
    Default = Enum.KeyCode.RightControl,
    ChangedCallback = function(newKey)
        print("New Keybind:", newKey)
    end
})
```

### Console
```lua
local console = Main:Console({ Height = 350 })

console:Log("Welcome to the console!")
console:Log("This is a log entry.", Color3.fromRGB(150, 150, 150))
```
#### Clear Console
```lua
console:Clear()
```

#### Popup
```lua
Window:ShowPopup("Hello World", "The quick brown fox jumps", function()
    print("Confirm")
end, function()
    print("Cancel")
end)
```

#### 5. Configuration System
The library automatically handles saving and loading if you provide a `Flag` in your elements.

```lua
-- Save Settings
Window:SaveConfig("MyConfig")

-- Load Settings
Window:LoadConfig("MyConfig")

-- Set Theme
Window:SetTheme("Light") -- Light, Dark, Purple
```

## 6. Utilities

#### Notifications
Send a toast notification to the user.
```lua
Window:Notify("Title", "Message content here", 3) -- Title, Message, Duration (seconds)
```

#### Space
```lua
MainTab:Space()
```

#### Selecttab
```lua
MainTab:SelectTab()
```

#### Live Flags (Switch)
You can access or modify element values directly using `Window.Switch`. This is useful for loops or external scripts.

**Note:** You must assign a `Flag` to the element to use this feature.

```lua
-- Example Element
-- MainTab:Toggle({ Title = "Auto Farm", Flag = "FarmEnabled", ... })

-- Read value
if Window.Flags.FarmEnabled then
    print("Auto Farm is ON")
end

-- Set value (Updates UI automatically)
Window.Switch.FarmEnabled = false 
```

## 📜 Credits
Developed by **arsyny1x**.