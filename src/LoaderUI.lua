local TweenService = game:GetService("TweenService")

local Theme = {
	Panel = Color3.fromRGB(17, 17, 17),
	Surface = Color3.fromRGB(23, 23, 23),
	Surface2 = Color3.fromRGB(31, 31, 31),
	Surface3 = Color3.fromRGB(39, 39, 39),
	Border = Color3.fromRGB(51, 51, 51),
	Border2 = Color3.fromRGB(71, 71, 71),
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
	shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
	shadow.Size = UDim2.fromOffset(368, 112)
	shadow.BackgroundColor3 = Color3.new(0, 0, 0)
	shadow.BackgroundTransparency = 0.48
	shadow.BorderSizePixel = 0
	shadow.Parent = screenGui
	corner(shadow, 30)

	local card = Instance.new("Frame")
	card.Name = "Card"
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.fromOffset(360, 104)
	card.BackgroundColor3 = Theme.Surface2
	card.BorderSizePixel = 0
	card.Parent = screenGui
	corner(card, 28)

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Border2
	stroke.Transparency = 0.25
	stroke.Thickness = 1
	stroke.Parent = card

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.BackgroundTransparency = 1
	status.Position = UDim2.fromOffset(28, 24)
	status.Size = UDim2.new(1, -88, 0, 18)
	status.Font = Enum.Font.GothamSemibold
	status.Text = "Preparing interface"
	status.TextColor3 = Theme.Muted
	status.TextSize = 13
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Parent = card

	local statusGradient = Instance.new("UIGradient")
	statusGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.Muted),
		ColorSequenceKeypoint.new(0.25, Theme.Muted),
		ColorSequenceKeypoint.new(0.45, Theme.Text),
		ColorSequenceKeypoint.new(0.65, Theme.Text),
		ColorSequenceKeypoint.new(0.85, Theme.Muted),
		ColorSequenceKeypoint.new(1, Theme.Muted),
	})
	statusGradient.Offset = Vector2.new(-1, 0)
	statusGradient.Parent = status

	local statusTween = TweenService:Create(
		statusGradient,
		TweenInfo.new(1.6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
		{ Offset = Vector2.new(1, 0) }
	)
	statusTween:Play()

	local percentage = Instance.new("TextLabel")
	percentage.Name = "Percentage"
	percentage.BackgroundTransparency = 1
	percentage.Position = UDim2.new(1, -68, 0, 24)
	percentage.Size = UDim2.fromOffset(40, 18)
	percentage.Font = Enum.Font.GothamMedium
	percentage.Text = "0%"
	percentage.TextColor3 = Theme.Muted
	percentage.TextSize = 13
	percentage.TextXAlignment = Enum.TextXAlignment.Right
	percentage.Parent = card

	local rail = Instance.new("Frame")
	rail.Name = "Progress"
	rail.Position = UDim2.new(0, 28, 1, -32)
	rail.Size = UDim2.new(1, -56, 0, 8)
	rail.BackgroundColor3 = Theme.Surface3
	rail.BorderSizePixel = 0
	rail.Parent = card
	corner(rail, 4)

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = rail
	corner(fill, 4)

	local self = setmetatable({}, LoaderUI)
	self.ScreenGui = screenGui
	self.Status = status
	self.StatusTween = statusTween
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
		Enum.EasingStyle.Quint,
		0.28,
		true
	)
end

function LoaderUI:Destroy()
	self.StatusTween:Cancel()
	self.ScreenGui:Destroy()
end

return LoaderUI
