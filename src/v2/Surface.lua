local Util = require("v2/Util")

local URL = "https://raw.githubusercontent.com/j0z4fx/PureLib/f7898c40a0b834b29595dbd0508105e99afb9517/assets/continuous-corners-p45.png"
local asset

local function getAsset()
	if asset ~= nil then return asset or nil end
	local loadAsset = type(getcustomasset) == "function" and getcustomasset
		or type(getsynasset) == "function" and getsynasset
	if type(writefile) ~= "function" or not loadAsset then
		asset = false
		return nil
	end
	local ok, value = pcall(function()
		local path = "PureLib-continuous-corners-p45.png"
		writefile(path, game:HttpGet(URL))
		return loadAsset(path)
	end)
	asset = ok and value or false
	return asset or nil
end

return function(parent, color, radius, position, size)
	local image = getAsset()
	if image then
		return Util.new("ImageLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = image,
			ImageColor3 = color,
			Position = position or UDim2.fromOffset(0, 0),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(48, 48, 80, 80),
			SliceScale = radius / 48,
			Size = size or UDim2.fromScale(1, 1),
		}, parent)
	end
	local frame = Util.new("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Position = position or UDim2.fromOffset(0, 0),
		Size = size or UDim2.fromScale(1, 1),
	}, parent)
	Util.corner(frame, radius)
	return frame
end
