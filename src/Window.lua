local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Window = {}
Window.__index = Window

local DEFAULTS = {
	Name = "PureLib",
	Title = "PureLib",
	Size = UDim2.fromOffset(800, 450),
	BackgroundColor = Color3.fromRGB(18, 18, 22),
	TitleBarColor = Color3.fromRGB(24, 24, 30),
	TextColor = Color3.fromRGB(240, 240, 245),
}

local function getOption(options, key)
	local value = options[key]

	if value == nil then
		return DEFAULTS[key]
	end

	return value
end

local function parentScreenGui(screenGui)
	if type(gethui) == "function" then
		local hiddenUi = gethui()
		assert(hiddenUi, "PureLib: gethui() returned nil")

		screenGui.Parent = hiddenUi
		assert(screenGui.Parent == hiddenUi, "PureLib could not mount to gethui()")

		return hiddenUi
	end

	local player = Players.LocalPlayer
	assert(player, "PureLib must be executed on the client")

	local playerGui = player:WaitForChild("PlayerGui")
	screenGui.Parent = playerGui
	assert(screenGui.Parent == playerGui, "PureLib could not parent its ScreenGui")

	return playerGui
end

function Window.new(options)
	options = options or {}

	local self = setmetatable({}, Window)
	self._connections = {}

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = getOption(options, "Name")
	screenGui.Enabled = true
	screenGui.DisplayOrder = 100
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local uiParent = parentScreenGui(screenGui)

	local root = Instance.new("Frame")
	root.Name = "Window"
	root.Active = true
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Size = getOption(options, "Size")
	root.Visible = true
	root.BackgroundColor3 = getOption(options, "BackgroundColor")
	root.BorderSizePixel = 0
	root.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = root

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(75, 75, 90)
	stroke.Thickness = 1
	stroke.Transparency = 0
	stroke.Parent = root

	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Active = true
	titleBar.Size = UDim2.new(1, 0, 0, 48)
	titleBar.BackgroundColor3 = getOption(options, "TitleBarColor")
	titleBar.BorderSizePixel = 0
	titleBar.Parent = root

	local titleBarCorner = Instance.new("UICorner")
	titleBarCorner.CornerRadius = UDim.new(0, 10)
	titleBarCorner.Parent = titleBar

	local titleBarFill = Instance.new("Frame")
	titleBarFill.Name = "BottomFill"
	titleBarFill.AnchorPoint = Vector2.new(0, 1)
	titleBarFill.Position = UDim2.fromScale(0, 1)
	titleBarFill.Size = UDim2.new(1, 0, 0, 10)
	titleBarFill.BackgroundColor3 = titleBar.BackgroundColor3
	titleBarFill.BorderSizePixel = 0
	titleBarFill.Parent = titleBar

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Position = UDim2.fromOffset(18, 0)
	title.Size = UDim2.new(1, -36, 1, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamSemibold
	title.Text = getOption(options, "Title")
	title.TextColor3 = getOption(options, "TextColor")
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleBar

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Position = UDim2.fromOffset(0, 48)
	content.Size = UDim2.new(1, 0, 1, -48)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ClipsDescendants = true
	content.Parent = root

	local dragging = false
	local dragStart
	local startPosition
	local activeDragInput

	table.insert(self._connections, titleBar.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		dragging = true
		dragStart = input.Position
		startPosition = root.Position

		local endedConnection
		endedConnection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				endedConnection:Disconnect()
			end
		end)
	end))

	table.insert(self._connections, titleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			activeDragInput = input
		end
	end))

	table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
		if not dragging or input ~= activeDragInput then
			return
		end

		local delta = input.Position - dragStart
		root.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end))

	self.ScreenGui = screenGui
	self.Root = root
	self.TitleBar = titleBar
	self.Content = content
	self.Parent = uiParent

	return self
end

function Window:SetVisible(visible)
	self.ScreenGui.Enabled = visible
end

function Window:Destroy()
	for _, connection in self._connections do
		connection:Disconnect()
	end

	table.clear(self._connections)
	self.ScreenGui:Destroy()
end

return Window
