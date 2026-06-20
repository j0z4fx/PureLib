local Theme = {
	Panel = Color3.fromRGB(17, 17, 17),
	Surface = Color3.fromRGB(23, 23, 23),
	Surface2 = Color3.fromRGB(31, 31, 31),
	Border = Color3.fromRGB(51, 51, 51),
	Text = Color3.fromRGB(245, 245, 245),
	Muted = Color3.fromRGB(184, 184, 184),
	Accent = Color3.fromRGB(247, 106, 118),
	AccentHover = Color3.fromRGB(255, 128, 138),
}

local LoaderUI = {}
LoaderUI.__index = LoaderUI

local function corner(parent, radius)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius)
	item.Parent = parent
end

function LoaderUI.new(parent)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PureLibLoader"
	screenGui:SetAttribute("PureLib", true)
	screenGui.DisplayOrder = 101
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = parent

	local card = Instance.new("Frame")
	card.Name = "Card"
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.fromOffset(340, 142)
	card.BackgroundColor3 = Theme.Panel
	card.BorderSizePixel = 0
	card.Parent = screenGui
	corner(card, 12)

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Border
	stroke.Thickness = 1
	stroke.Parent = card

	local mark = Instance.new("Frame")
	mark.Name = "Mark"
	mark.Position = UDim2.fromOffset(20, 20)
	mark.Size = UDim2.fromOffset(38, 38)
	mark.BackgroundColor3 = Theme.Accent
	mark.BorderSizePixel = 0
	mark.Parent = card
	corner(mark, 10)

	local markGradient = Instance.new("UIGradient")
	markGradient.Color = ColorSequence.new(Theme.AccentHover, Theme.Accent)
	markGradient.Rotation = 135
	markGradient.Parent = mark

	local glyph = Instance.new("TextLabel")
	glyph.BackgroundTransparency = 1
	glyph.Size = UDim2.fromScale(1, 1)
	glyph.Font = Enum.Font.GothamBold
	glyph.Text = "P"
	glyph.TextColor3 = Theme.Text
	glyph.TextSize = 20
	glyph.Parent = mark

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(72, 19)
	title.Size = UDim2.new(1, -92, 0, 22)
	title.Font = Enum.Font.GothamSemibold
	title.Text = "PureLib"
	title.TextColor3 = Theme.Text
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = card

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.BackgroundTransparency = 1
	status.Position = UDim2.fromOffset(72, 43)
	status.Size = UDim2.new(1, -92, 0, 18)
	status.Font = Enum.Font.Gotham
	status.Text = "Preparing interface"
	status.TextColor3 = Theme.Muted
	status.TextSize = 12
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Parent = card

	local rail = Instance.new("Frame")
	rail.Name = "Progress"
	rail.Position = UDim2.new(0, 20, 1, -38)
	rail.Size = UDim2.new(1, -40, 0, 6)
	rail.BackgroundColor3 = Theme.Surface2
	rail.BorderSizePixel = 0
	rail.Parent = card
	corner(rail, 3)

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = rail
	corner(fill, 3)

	local self = setmetatable({}, LoaderUI)
	self.ScreenGui = screenGui
	self.Status = status
	self.Fill = fill
	return self
end

function LoaderUI:Set(status, progress)
	self.Status.Text = status
	self.Fill:TweenSize(
		UDim2.fromScale(math.clamp(progress, 0, 1), 1),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.16,
		true
	)
end

function LoaderUI:Destroy()
	self.ScreenGui:Destroy()
end

return LoaderUI
