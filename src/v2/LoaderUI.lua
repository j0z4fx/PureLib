local TweenService = game:GetService("TweenService")

local Util = require("v2/Util")
local Surface = require("v2/Surface")

local LoaderUI = {}
LoaderUI.__index = LoaderUI

function LoaderUI.new(parent, theme)
	local gui = Util.new("ScreenGui", {
		Name = "PureLibLoader",
		DisplayOrder = 101,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, parent)
	gui:SetAttribute("PureLib", true)
	local card = Util.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(360, 76),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, gui)
	Surface(card, theme.Surface, 18)
	local status = Util.new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 16),
		Size = UDim2.new(1, -72, 0, 20),
		Font = Enum.Font.Gotham,
		Text = "Preparing interface",
		TextColor3 = theme.Muted,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)
	local gradient = Util.new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, theme.Muted),
			ColorSequenceKeypoint.new(0.3, theme.Muted),
			ColorSequenceKeypoint.new(0.5, theme.Text),
			ColorSequenceKeypoint.new(0.7, theme.Muted),
			ColorSequenceKeypoint.new(1, theme.Muted),
		}),
		Offset = Vector2.new(-1, 0),
	}, status)
	local shimmer = TweenService:Create(
		gradient,
		TweenInfo.new(1.6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
		{ Offset = Vector2.new(1, 0) }
	)
	shimmer:Play()
	local percentage = Util.new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -56, 0, 16),
		Size = UDim2.fromOffset(40, 20),
		Font = Enum.Font.GothamMedium,
		Text = "0%",
		TextColor3 = theme.Muted,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, card)
	local track = Util.new("Frame", {
		Position = UDim2.fromOffset(16, 52),
		Size = UDim2.new(1, -32, 0, 8),
		BackgroundColor3 = theme.Surface3,
		BorderSizePixel = 0,
	}, card)
	Util.corner(track, 4)
	local fill = Util.new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
	}, track)
	Util.corner(fill, 4)
	return setmetatable({
		ScreenGui = gui,
		Status = status,
		Percentage = percentage,
		Fill = fill,
		Shimmer = shimmer,
	}, LoaderUI)
end

function LoaderUI:Set(text, progress)
	progress = math.clamp(progress, 0, 1)
	self.Status.Text = text
	self.Percentage.Text = string.format("%d%%", math.floor(progress * 100 + 0.5))
	TweenService:Create(
		self.Fill,
		TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = UDim2.new(progress, 0, 1, 0) }
	):Play()
end

function LoaderUI:Destroy()
	self.Shimmer:Cancel()
	self.ScreenGui:Destroy()
end

return LoaderUI
