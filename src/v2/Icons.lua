local Icons = {}
local Lucide = require("v2/Lucide")

local atlas = "rbxasset://textures/u3lntJIKD2kYIeT.png"
local common = {
	inbox = Vector2.new(650, 350),
	send = Vector2.new(400, 950),
	heart = Vector2.new(400, 575),
	settings = Vector2.new(650, 350),
	menu = Vector2.new(400, 950),
	check = Vector2.new(400, 575),
	["chevron-down"] = Vector2.new(650, 350),
	x = Vector2.new(400, 575),
}

function Icons.apply(image, icon)
	if type(icon) == "table" then
		image.Image = icon.Image or ""
		image.ImageRectOffset = icon.Offset or Vector2.zero
		image.ImageRectSize = icon.Size or Vector2.new(24, 24)
		return
	end
	local lucide = Lucide.GetAsset(tostring(icon):lower())
	if lucide then
		image.Image = lucide.Url
		image.ImageRectOffset = lucide.ImageRectOffset
		image.ImageRectSize = lucide.ImageRectSize
		return
	end
	image.Image = atlas
	image.ImageRectOffset = common[tostring(icon):lower()] or common.settings
	image.ImageRectSize = Vector2.new(24, 24)
end

return Icons
