# Repica Mac UI Library 🍎

A modern, sleek, and macOS-inspired User Interface library for Roblox scripts. Designed for developers who want a clean, professional look for their hubs with built-in configuration handling.

## ✨ Features

- **MacOS Aesthetic**: Authentic look with "traffic light" window controls, sidebar navigation, and smooth animations.
- **Fully Interactive**: Draggable, Resizable, and Minimizable window.
- **Theme System**: Built-in `Light`, `Dark`, and `Purple` themes with dynamic switching.
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

## 🛠️ Documentation

### 1. Create a Window
```lua
local Window = Library.CreateWindow({
	Title = "MacHub Premium",
	Size = UDim2.fromOffset(550, 350),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Theme = "Light",
	ToggleKey = Enum.KeyCode.RightControl,
	Folder = "MacHub Premium"
})
```

### 2. Create a Tab
```lua
local MainTab = Window:CreateTab({
    Name = "Main",
    Subtitle = "Auto Farm & Stats",
    Icon = "a-arrow-down"
}) 

```

### 3. Add Elements

#### Section
Used to group elements visually.
```lua
MainTab:Section({ 
    Head = "Selection", 
    Body = "Hello World" 
})
```

#### Button
```lua
MainTab:Button({
    Title = "Button",
    Icon = "Button",
    Callback = function()
        print("Button Cllicked")
    end
})
```

#### Toggle
Supports `Flag` for config saving.
```lua
MainTab:Toggle({
    Title = "Toggle",
    Default = false,
    Flag = "Toggle", -- Unique identifier for config
    Callback = function(value)
        print("Auto Attack:", value)
    end
})
```

#### Slider
Supports `Flag` for config saving.
```lua
MainTab:Slider({
    Title = "Slider",
    Min = 16,
    Max = 100,
    Default = 16,
    Flag = "Slider",
    Callback = function(value)
        print("Slider value:", value)
    end
})
```

#### Dropdown
Supports `Flag` for config saving.
```lua
MainTab:Dropdown({
    Title = "Select Weapon",
    Values = {"Melee", "Sword", "Fruit"},
    Value = "Melee", -- Default
    Flag = "WeaponSelector",
    Callback = function(value)
        print("Selected:", value)
    end
})
```

### Textinput
```lua
MainTab:Input({ 
    Title = "Text input",
	Icon = "play",
	Callback = function(v) 
		print("New input:", v)
    end
})
```

#### Keybind
```lua
MainTab:Keybind({
    Title = "Toggle Menu",
    Default = Enum.KeyCode.RightControl,
    ChangedCallback = function(newKey)
        print("New Keybind:", newKey)
    end
})
```

### 4. Configuration System
The library automatically handles saving and loading if you provide a `Flag` in your elements.

```lua
-- Save Settings
Window:SaveConfig("MyConfig")

-- Load Settings
Window:LoadConfig("MyConfig")

-- Set Theme
Window:SetTheme("Light") -- Light, Dark, Purple
```

### 5. Utilities

#### Notifications
Send a toast notification to the user.
```lua
Window:Notify("Title", "Message content here", 3) -- Title, Message, Duration (seconds)
```

#### Live Flags (Switch)
You can access or modify element values directly using `Window.Switch`. This is useful for loops or external cripts.

```lua
-- Read value
if Window.Flags.Toggle then
    print("Auto Farm is ON")
end

-- Set value (Updates UI automatically)
Window.Flags.Toggle = false 
```

## 📜 Credits
Developed by **arsyny1x**.
