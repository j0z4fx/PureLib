local AssetService = game:GetService("AssetService")

local IMAGE_SIZE = 64
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
		local aaRange = 0.08

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
		local surface = Instance.new("Frame")
		surface.BackgroundTransparency = 1
		surface.BorderSizePixel = 0
		surface.Position = position or UDim2.fromOffset(0, 0)
		surface.Size = size or UDim2.fromScale(1, 1)
		surface.Parent = parent

		local horizontal = Instance.new("Frame")
		horizontal.Position = UDim2.fromOffset(radius, 0)
		horizontal.Size = UDim2.new(1, -radius * 2, 1, 0)
		horizontal.BackgroundColor3 = color
		horizontal.BorderSizePixel = 0
		horizontal.Parent = surface

		local vertical = Instance.new("Frame")
		vertical.Position = UDim2.fromOffset(0, radius)
		vertical.Size = UDim2.new(1, 0, 1, -radius * 2)
		vertical.BackgroundColor3 = color
		vertical.BorderSizePixel = 0
		vertical.Parent = surface

		for _, cornerPosition in ipairs({
			UDim2.fromOffset(0, 0),
			UDim2.new(1, -radius * 2, 0, 0),
			UDim2.new(0, 0, 1, -radius * 2),
			UDim2.new(1, -radius * 2, 1, -radius * 2),
		}) do
			local patch = Instance.new("ImageLabel")
			patch.BackgroundTransparency = 1
			patch.BorderSizePixel = 0
			patch.ImageContent = imageContent
			patch.ImageColor3 = color
			patch.Position = cornerPosition
			patch.ScaleType = Enum.ScaleType.Stretch
			patch.Size = UDim2.fromOffset(radius * 2, radius * 2)
			patch.Parent = surface
		end

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
