local AssetService = game:GetService("AssetService")

local IMAGE_SIZE = 512
local image
local content

local function getContent()
	if content ~= nil then
		return content or nil
	end

	local loaded, value = pcall(function()
		local editableImage = AssetService:CreateEditableImage({
			Size = Vector2.new(IMAGE_SIZE, IMAGE_SIZE),
		})
		assert(editableImage, "Could not load EditableImage canvas.")

		local pixelBuffer = buffer.create(IMAGE_SIZE * IMAGE_SIZE * 4)
		local byteOffset = 0
		local aaRange = 0.015

		for y = 1, IMAGE_SIZE do
			for x = 1, IMAGE_SIZE do
				local nx = (x - IMAGE_SIZE / 2) / (IMAGE_SIZE / 2)
				local ny = (y - IMAGE_SIZE / 2) / (IMAGE_SIZE / 2)
				local squircleValue = math.abs(nx) ^ 4.5 + math.abs(ny) ^ 4.5
				local alpha = 0

				if squircleValue <= 1 - aaRange then
					alpha = 255
				elseif squircleValue < 1 + aaRange then
					local t = (squircleValue - (1 - aaRange)) / (aaRange * 2)
					alpha = math.floor((1 - t) * 255)
				end

				buffer.writeu8(pixelBuffer, byteOffset, 255)
				buffer.writeu8(pixelBuffer, byteOffset + 1, 255)
				buffer.writeu8(pixelBuffer, byteOffset + 2, 255)
				buffer.writeu8(pixelBuffer, byteOffset + 3, alpha)
				byteOffset += 4
			end
		end

		editableImage:WritePixelsBuffer(
			Vector2.zero,
			Vector2.new(IMAGE_SIZE, IMAGE_SIZE),
			pixelBuffer
		)
		image = editableImage
		return Content.fromObject(editableImage)
	end)

	content = loaded and value or false
	return content or nil
end

return function(parent, color, radius, position, size)
	local imageContent = getContent()

	if imageContent then
		local surface = Instance.new("ImageLabel")
		surface.BackgroundTransparency = 1
		surface.BorderSizePixel = 0
		surface.ImageContent = imageContent
		surface.ImageColor3 = color
		surface.Position = position or UDim2.fromOffset(0, 0)
		surface.ScaleType = Enum.ScaleType.Stretch
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
