local URL = "https://raw.githubusercontent.com/j0z4fx/PureLib/f7898c40a0b834b29595dbd0508105e99afb9517/assets/continuous-corners-p45.png"
local asset

local function getAsset()
	if asset ~= nil then
		return asset or nil
	end

	local loadAsset = type(getcustomasset) == "function" and getcustomasset
		or type(getsynasset) == "function" and getsynasset

	if type(writefile) ~= "function" or not loadAsset then
		asset = false
		return nil
	end

	local loaded, value = pcall(function()
		local path = "PureLib-continuous-corners-p45.png"
		writefile(path, game:HttpGet(URL))
		return loadAsset(path)
	end)

	asset = loaded and value or false
	return asset or nil
end

return function(parent, color, radius, position, size)
	local image = getAsset()

	if image then
		local surface = Instance.new("ImageLabel")
		surface.BackgroundTransparency = 1
		surface.BorderSizePixel = 0
		surface.Image = image
		surface.ImageColor3 = color
		surface.Position = position or UDim2.fromOffset(0, 0)
		surface.ScaleType = Enum.ScaleType.Slice
		surface.SliceCenter = Rect.new(48, 48, 80, 80)
		surface.SliceScale = radius / 48
		surface.Size = size or UDim2.fromScale(1, 1)
		surface.Parent = parent
		return surface
	end

	local surface = Instance.new("Frame")
	surface.BackgroundColor3 = color
	surface.BorderSizePixel = 0
	surface.Position = position or UDim2.fromOffset(0, 0)
	surface.Size = size or UDim2.fromScale(1, 1)
	surface.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = surface
	return surface
end
