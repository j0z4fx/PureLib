local Players = game:GetService("Players")

local Theme = require("v2/Theme")
local Motion = require("v2/Motion")
local Window = require("v2/Window")
local LoaderUI = require("v2/LoaderUI")

local function parents()
	local output, seen = {}, {}
	local function add(parent)
		if parent and not seen[parent] then
			seen[parent] = true
			table.insert(output, parent)
		end
	end
	if type(gethui) == "function" then add(gethui()) end
	if Players.LocalPlayer then add(Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")) end
	return output
end

local function cleanup()
	for _, parent in ipairs(parents()) do
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("ScreenGui")
				and (child:GetAttribute("PureLib") == true or child.Name == "PureLib" or child.Name == "PureLibLoader")
			then
				child:Destroy()
			end
		end
	end
end

cleanup()
local defaultTheme = Theme.create()
local parent = parents()[1]
if not parent then
	local player = assert(Players.LocalPlayer, "PureLib must run on client")
	parent = player:WaitForChild("PlayerGui")
end
local loader = LoaderUI.new(parent, defaultTheme)

local PureLib = {
	Theme = Theme.Default,
	Version = "2.0.0",
}

local function showcase(window)
	local controls = window:AddTab({ Name = "Controls", Icon = "settings", Columns = 3 })
	controls:AddControl(1, "title", { Label = "Selection" })
	controls:AddControl(1, "switch", { Label = "Switch", Value = true })
	controls:AddControl(1, "checkbox", { Label = "Checkbox", Value = true })
	controls:AddControl(1, "radio", { Label = "Radio one", Group = "demo", Value = true })
	controls:AddControl(1, "radio", { Label = "Radio two", Group = "demo" })
	controls:AddControl(1, "divider")
	controls:AddControl(1, "button", { Label = "Filled button", Icon = "check" })
	controls:AddControl(1, "button", { Label = "Outlined", Variant = "outlined" })

	controls:AddControl(2, "title", { Label = "Sliders" })
	controls:AddControl(2, "slider", { Label = "Standard", Value = 40 })
	controls:AddControl(2, "centered-slider", { Label = "Centered", Value = 65 })
	controls:AddControl(2, "range-slider", { Label = "Range", Lower = 25, Upper = 75 })
	controls:AddControl(2, "progress", { Value = 0.62 })
	controls:AddControl(2, "chip", { Label = "Filter chip", Variant = "outlined" })

	controls:AddControl(3, "title", { Label = "Inputs" })
	controls:AddControl(3, "text-field", { Label = "Name", Placeholder = "Type here" })
	controls:AddControl(3, "dropdown", { Label = "Choice", Values = { "Alpha", "Beta", "Gamma" }, Value = "Alpha" })
	controls:AddControl(3, "keybind", { Label = "Keybind", Value = Enum.KeyCode.RightShift })
	controls:AddControl(3, "color", { Label = "Accent", Value = window.Theme.Accent })
	controls:AddControl(3, "list", { Label = "List item", SupportingText = "Supporting text" })

	local overlays = window:AddTab({ Name = "Overlays", Icon = "menu", Columns = 1 })
	overlays:AddControl(1, "title", { Label = "Transient surfaces" })
	overlays:AddControl(1, "button", {
		Label = "Show snackbar",
		Callback = function() window:ShowSnackbar({ Text = "PureLib snackbar" }) end,
	})
	overlays:AddControl(1, "button", {
		Label = "Show dialog",
		Variant = "tonal",
		Callback = function() window:ShowDialog({ Title = "PureLib", Text = "Compact Material 3 dialog." }) end,
	})
end

function PureLib:CreateWindow(options)
	options = options or {}
	local theme = Theme.create(options.Theme)
	local motion = Motion.new()
	local window = Window.new(options, theme, motion)
	local activeLoader = loader
	loader = nil
	window.Root.Visible = activeLoader == nil
	if options.Showcase then showcase(window) end

	if activeLoader then
		task.spawn(function()
			local steps = {
				"Previous instances cleaned",
				"Theme tokens resolved",
				"Control system mounted",
				"Interface ready",
			}
			local delay = math.max(0, tonumber(fakeLoadDelay) or 2) / #steps
			for index, step in ipairs(steps) do
				activeLoader:Set(step, index / #steps)
				if delay > 0 then task.wait(delay) end
			end
			window.Root.Visible = true
			activeLoader:Destroy()
		end)
	end
	return window
end

return PureLib
