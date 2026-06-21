local defaults = {
	Bg = Color3.fromRGB(13, 13, 13),
	Panel = Color3.fromRGB(17, 17, 17),
	Surface = Color3.fromRGB(23, 23, 23),
	Surface2 = Color3.fromRGB(31, 31, 31),
	Surface3 = Color3.fromRGB(39, 39, 39),
	Border = Color3.fromRGB(51, 51, 51),
	Border2 = Color3.fromRGB(71, 71, 71),
	BorderHot = Color3.fromRGB(138, 138, 138),
	Text = Color3.fromRGB(245, 245, 245),
	Muted = Color3.fromRGB(184, 184, 184),
	Dim = Color3.fromRGB(119, 119, 119),
	Accent = Color3.fromRGB(247, 106, 118),
	AccentHover = Color3.fromRGB(255, 128, 138),
	Danger = Color3.fromRGB(255, 92, 103),
	Success = Color3.fromRGB(85, 210, 143),
	Warning = Color3.fromRGB(226, 184, 79),
	Info = Color3.fromRGB(116, 166, 255),
}

local Theme = {}

function Theme.create(overrides)
	local result = table.clone(defaults)
	for token, value in pairs(overrides or {}) do
		assert(defaults[token] ~= nil, "Unknown PureLib theme token: " .. tostring(token))
		assert(typeof(value) == "Color3", "Theme token " .. token .. " must be Color3")
		result[token] = value
	end
	return result
end

Theme.Default = defaults
Theme.Space = { 4, 8, 12, 16, 20, 24 }
Theme.Type = {
	Body = 14,
	Label = 13,
	Support = 12,
	Title = 14,
}
Theme.Shape = {
	Small = 6,
	Medium = 10,
	Large = 16,
	Full = 999,
}

return Theme
