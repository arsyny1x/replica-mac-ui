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
local Library = loadstring(game:HttpGet("YOUR_RAW_GITHUB_URL_HERE"))()
```

## 🛠️ Documentation

### 1. Create a Window
```lua
local Window = Library.CreateWindow({
    Title = "MacHub Premium",
    Size = UDim2.fromOffset(550, 450),
    Position = UDim2.new(0.5, -275, 0.5, -175), -- Center
    Theme = "Light", -- Options: "Light", "Dark", "Purple"
    ToggleKey = Enum.KeyCode.RightControl,
    Folder = "MacHub" -- Folder name for config files
})
```

### 2. Create a Tab
```lua
-- Arguments: Name, Subtitle, Icon Name (Lucide)
local MainTab = Window:CreateTab("Main", "Auto Farm & Stats", "home") 
```

### 3. Add Elements

#### Section
Used to group elements visually.
```lua
MainTab:Section({ 
    Head = "Farming", 
    Body = "Main settings for auto farm" 
})
```

#### Button
```lua
MainTab:Button({
    Title = "Start Farm",
    Icon = "play",
    Callback = function()
        print("Farm started!")
    end
})
```

#### Toggle
Supports `Flag` for config saving.
```lua
MainTab:Toggle({
    Title = "Auto Attack",
    Default = false,
    Flag = "AutoAttack", -- Unique identifier for config
    Callback = function(value)
        print("Auto Attack:", value)
    end
})
```

#### Slider
Supports `Flag` for config saving.
```lua
MainTab:Slider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
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
```

## 📜 Credits
Developed by **arsyny1x**.