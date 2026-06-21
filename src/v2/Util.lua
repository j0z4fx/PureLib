local Util = {}

function Util.new(className, properties, parent)
	local instance = Instance.new(className)
	for key, value in pairs(properties or {}) do
		instance[key] = value
	end
	instance.Parent = parent
	return instance
end

function Util.corner(parent, radius)
	return Util.new("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

function Util.stroke(parent, color, thickness)
	return Util.new("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

function Util.connect(owner, signal, callback)
	local connection = signal:Connect(callback)
	table.insert(owner._connections, connection)
	return connection
end

function Util.row(parent, height)
	return Util.new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height or 40),
	}, parent)
end

function Util.label(parent, text, theme, size)
	return Util.new("TextLabel", {
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = tostring(text or ""),
		TextColor3 = theme.Text,
		TextSize = size or 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, parent)
end

return Util
