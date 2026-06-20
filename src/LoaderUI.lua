local Theme = {
	Panel = Color3.fromRGB(17, 17, 17),
	Surface = Color3.fromRGB(23, 23, 23),
	Surface2 = Color3.fromRGB(31, 31, 31),
	Surface3 = Color3.fromRGB(39, 39, 39),
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

	local shadow = Instance.new("Frame")
	shadow.Name = "Elevation"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
	shadow.Size = UDim2.fromOffset(360, 172)
	shadow.BackgroundColor3 = Color3.new(0, 0, 0)
	shadow.BackgroundTransparency = 0.55
	shadow.BorderSizePixel = 0
	shadow.Parent = screenGui
	corner(shadow, 16)

	local card = Instance.new("Frame")
	card.Name = "Card"
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.fromOffset(360, 172)
	card.BackgroundColor3 = Theme.Surface
	card.BorderSizePixel = 0
	card.Parent = screenGui
	corner(card, 16)

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Border
	stroke.Thickness = 1
	stroke.Parent = card

	local mark = Instance.new("Frame")
	mark.Name = "Mark"
	mark.Position = UDim2.fromOffset(24, 24)
	mark.Size = UDim2.fromOffset(48, 48)
	mark.BackgroundColor3 = Theme.Surface3
	mark.BorderSizePixel = 0
	mark.Parent = card
	corner(mark, 14)

	local glyph = Instance.new("TextLabel")
	glyph.BackgroundTransparency = 1
	glyph.Size = UDim2.fromScale(1, 1)
	glyph.Font = Enum.Font.GothamBold
	glyph.Text = "P"
	glyph.TextColor3 = Theme.AccentHover
	glyph.TextSize = 22
	glyph.Parent = mark

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(88, 26)
	title.Size = UDim2.new(1, -112, 0, 24)
	title.Font = Enum.Font.GothamSemibold
	title.Text = "PureLib"
	title.TextColor3 = Theme.Text
	title.TextSize = 20
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = card

	local subtitle = Instance.new("TextLabel")
	subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.fromOffset(88, 51)
	subtitle.Size = UDim2.new(1, -112, 0, 18)
	subtitle.Font = Enum.Font.Gotham
	subtitle.Text = "Preparing your interface"
	subtitle.TextColor3 = Theme.Muted
	subtitle.TextSize = 13
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.Parent = card

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.BackgroundTransparency = 1
	status.Position = UDim2.fromOffset(24, 102)
	status.Size = UDim2.new(1, -88, 0, 18)
	status.Font = Enum.Font.GothamMedium
	status.Text = "Preparing interface"
	status.TextColor3 = Theme.Muted
	status.TextSize = 12
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Parent = card

	local percentage = Instance.new("TextLabel")
	percentage.Name = "Percentage"
	percentage.BackgroundTransparency = 1
	percentage.Position = UDim2.new(1, -64, 0, 102)
	percentage.Size = UDim2.fromOffset(40, 18)
	percentage.Font = Enum.Font.GothamMedium
	percentage.Text = "0%"
	percentage.TextColor3 = Theme.Muted
	percentage.TextSize = 12
	percentage.TextXAlignment = Enum.TextXAlignment.Right
	percentage.Parent = card

	local rail = Instance.new("Frame")
	rail.Name = "Progress"
	rail.Position = UDim2.new(0, 24, 1, -36)
	rail.Size = UDim2.new(1, -48, 0, 4)
	rail.BackgroundColor3 = Theme.Surface2
	rail.BorderSizePixel = 0
	rail.Parent = card
	corner(rail, 2)

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = rail
	corner(fill, 2)

	local self = setmetatable({}, LoaderUI)
	self.ScreenGui = screenGui
	self.Status = status
	self.Percentage = percentage
	self.Fill = fill
	return self
end

function LoaderUI:Set(status, progress)
	progress = math.clamp(progress, 0, 1)
	self.Status.Text = status
	self.Percentage.Text = string.format("%d%%", math.floor(progress * 100 + 0.5))
	self.Fill:TweenSize(
		UDim2.fromScale(progress, 1),
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
