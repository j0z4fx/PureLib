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

-- C3 Bézier joined to straight edges; C3 continuity implies G3 continuity.
local G3_INSETS = {
	0.7188, 0.5957, 0.5139, 0.448, 0.3914, 0.3413,
	0.2962, 0.2553, 0.218, 0.1841, 0.1532, 0.1252,
	0.1002, 0.0781, 0.0588, 0.0425, 0.029, 0.0185,
	0.0106, 0.0053, 0.0022, 0.0006, 0.0001, 0,
}

local function g3Surface(parent, color, radius)
	local surface = Instance.new("Frame")
	surface.BackgroundTransparency = 1
	surface.BorderSizePixel = 0
	surface.Size = UDim2.fromScale(1, 1)
	surface.Parent = parent

	local middle = Instance.new("Frame")
	middle.Position = UDim2.fromOffset(0, radius)
	middle.Size = UDim2.new(1, 0, 1, -radius * 2)
	middle.BackgroundColor3 = color
	middle.BorderSizePixel = 0
	middle.Parent = surface

	local rowHeight = radius / #G3_INSETS
	for index, ratio in ipairs(G3_INSETS) do
		local inset = radius * ratio
		local y = (index - 1) * rowHeight

		for _, top in ipairs({ true, false }) do
			local row = Instance.new("Frame")
			row.Position = top
				and UDim2.new(0, inset, 0, y)
				or UDim2.new(0, inset, 1, -y - rowHeight)
			row.Size = UDim2.new(1, -inset * 2, 0, rowHeight + 0.05)
			row.BackgroundColor3 = color
			row.BorderSizePixel = 0
			row.Parent = surface
		end
	end
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
	card.Size = UDim2.fromOffset(360, 76)
	card.BackgroundTransparency = 1
	card.BorderSizePixel = 0
	card.Parent = screenGui
	g3Surface(card, Theme.Surface, 12)

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.BackgroundTransparency = 1
	status.Position = UDim2.fromOffset(16, 16)
	status.Size = UDim2.new(1, -72, 0, 20)
	status.Font = Enum.Font.Gotham
	status.Text = "Preparing interface"
	status.TextColor3 = Theme.Muted
	status.TextSize = 14
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
	percentage.Position = UDim2.new(1, -56, 0, 16)
	percentage.Size = UDim2.fromOffset(40, 20)
	percentage.Font = Enum.Font.GothamMedium
	percentage.Text = "0%"
	percentage.TextColor3 = Theme.Muted
	percentage.TextSize = 14
	percentage.TextXAlignment = Enum.TextXAlignment.Right
	percentage.Parent = card

	local rail = Instance.new("Frame")
	rail.Name = "Progress"
	rail.Position = UDim2.fromOffset(16, 52)
	rail.Size = UDim2.new(1, -32, 0, 8)
	rail.BackgroundTransparency = 1
	rail.BorderSizePixel = 0
	rail.Parent = card

	local fill = Instance.new("Frame")
	fill.Name = "ActiveIndicator"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = rail
	corner(fill, 4)

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Position = UDim2.fromOffset(4, 0)
	track.Size = UDim2.new(1, -4, 1, 0)
	track.BackgroundColor3 = Theme.Surface3
	track.BorderSizePixel = 0
	track.Parent = rail
	corner(track, 4)

	local self = setmetatable({}, LoaderUI)
	self.ScreenGui = screenGui
	self.Status = status
	self.StatusTween = statusTween
	self.Percentage = percentage
	self.Fill = fill
	self.Track = track
	return self
end

function LoaderUI:Set(status, progress)
	progress = math.clamp(progress, 0, 1)
	local gap = progress > 0 and progress < 1 and 4 or 0
	self.Status.Text = status
	self.Percentage.Text = string.format("%d%%", math.floor(progress * 100 + 0.5))
	self.Fill:TweenSize(
		UDim2.new(progress, -progress * gap, 1, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.3,
		true
	)
	self.Track:TweenPosition(
		UDim2.new(progress, (1 - progress) * gap, 0, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.3,
		true
	)
	self.Track:TweenSize(
		UDim2.new(1 - progress, -(1 - progress) * gap, 1, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.3,
		true
	)
end

function LoaderUI:Destroy()
	self.StatusTween:Cancel()
	self.ScreenGui:Destroy()
end

return LoaderUI
