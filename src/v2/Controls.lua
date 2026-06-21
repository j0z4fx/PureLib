local Controls = {
	button = require("v2/controls/Button"),
	["icon-button"] = require("v2/controls/IconButton"),
	iconbutton = require("v2/controls/IconButton"),
	checkbox = require("v2/controls/Checkbox"),
	radio = require("v2/controls/Radio"),
	switch = require("v2/controls/Switch"),
	toggle = require("v2/controls/Switch"),
	slider = require("v2/controls/Slider"),
	["centered-slider"] = require("v2/controls/CenteredSlider"),
	centeredslider = require("v2/controls/CenteredSlider"),
	["range-slider"] = require("v2/controls/RangeSlider"),
	rangeslider = require("v2/controls/RangeSlider"),
	["text-field"] = require("v2/controls/TextField"),
	textfield = require("v2/controls/TextField"),
	dropdown = require("v2/controls/Dropdown"),
	select = require("v2/controls/Dropdown"),
	keybind = require("v2/controls/Keybind"),
	color = require("v2/controls/ColorInput"),
	colorinput = require("v2/controls/ColorInput"),
	chip = require("v2/controls/Chip"),
	progress = require("v2/controls/Progress"),
	list = require("v2/controls/ListRow"),
	listrow = require("v2/controls/ListRow"),
	title = require("v2/controls/Title"),
	divider = require("v2/controls/Divider"),
}

return {
	create = function(ctx, parent, kind, options)
		local name = tostring(kind):lower()
		return assert(Controls[name], "Unknown PureLib control type: " .. name)(ctx, parent, options or {})
	end,
}
