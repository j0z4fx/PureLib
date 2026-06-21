# PureLib

Compact Material 3–inspired Roblox executor UI library.

```lua
fakeLoadDelay = 2

local PureLib = loadstring(game:HttpGet("IMMUTABLE_LOADER_URL"))()
local window = PureLib:CreateWindow()

local tab = window:AddTab({
    Name = "Settings",
    Icon = "settings",
    Columns = 1,
})

local enabled = tab:AddControl(1, "switch", {
    Label = "Enabled",
    Value = false,
    Callback = function(value)
        print(value)
    end,
})
```

## Controls

`button`, `icon-button`, `checkbox`, `radio`, `switch`, `slider`,
`centered-slider`, `range-slider`, `text-field`, `dropdown`, `keybind`,
`color`, `chip`, `progress`, `list`, `title`, and `divider`.

Every control supports `GetValue`, `SetVisible`, `SetDisabled`, `SetLabel`,
and `Destroy`. Value controls also support `SetValue`; range sliders expose
`SetRange`.

Use `CreateWindow({ Showcase = true })` to render the component gallery.

## Build

```powershell
.\tools\build-loader.ps1
```

The generated `loader.lua` contains all modules and performs no nested
`loadstring`.
