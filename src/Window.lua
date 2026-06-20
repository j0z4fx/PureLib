local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Theme = {
	Bg = Color3.fromRGB(13, 13, 13),
	Panel = Color3.fromRGB(17, 17, 17),
	Surface = Color3.fromRGB(23, 23, 23),
	Surface2 = Color3.fromRGB(31, 31, 31),
	Surface3 = Color3.fromRGB(39, 39, 39),
	Border = Color3.fromRGB(51, 51, 51),
	Border2 = Color3.fromRGB(71, 71, 71),
	BorderHot = Color3.fromRGB(138, 138, 138),
	Text = Color3.fromRGB(245, 245, 245),
	Muted = Color3.fromRGB(184, 184, 184),
	Dim = Color3.fromRGB(119, 119, 119),
	Accent = Color3.fromRGB(247, 106, 118),
	AccentHover = Color3.fromRGB(255, 128, 138),
	Danger = Color3.fromRGB(255, 92, 103),
	Success = Color3.fromRGB(85, 210, 143),
	Warning = Color3.fromRGB(226, 184, 79),
	Info = Color3.fromRGB(116, 166, 255),
}

local Window = {}
Window.__index = Window

local function mountGui(screenGui)
	if type(gethui) == "function" then
		screenGui.Parent = gethui()
	else
		local player = Players.LocalPlayer
		assert(player, "PureLib must run on the client")
		screenGui.Parent = player:WaitForChild("PlayerGui")
	end

	assert(screenGui.Parent, "PureLib could not mount its ScreenGui")
	return screenGui.Parent
end

function Window.new(options)
	options = options or {}

	local self = setmetatable({}, Window)
	self._connections = {}

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = options.Name or "PureLib"
	screenGui:SetAttribute("PureLib", true)
	screenGui.Enabled = true
	screenGui.DisplayOrder = 100
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local guiParent = mountGui(screenGui)

	local root = Instance.new("Frame")
	root.Name = "Window"
	root.Active = true
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.new(0.5, 0, 0.5, 0)
	root.Size = UDim2.new(0, 800, 0, 450)
	root.BackgroundColor3 = Theme.Surface
	root.BorderSizePixel = 0
	root.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = root

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Border
	stroke.Thickness = 1
	stroke.Parent = root

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Position = UDim2.new(0, 0, 0, 0)
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ClipsDescendants = true
	content.Parent = root

	local dragging = false
	local dragStart = nil
	local startPosition = nil
	local dragInput = nil

	local beganConnection = root.InputBegan:Connect(function(input)
		local inputType = input.UserInputType

		if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = root.Position
		end
	end)
	table.insert(self._connections, beganConnection)

	local endedConnection = UserInputService.InputEnded:Connect(function(input)
		local inputType = input.UserInputType

		if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	table.insert(self._connections, endedConnection)

	local changedConnection = root.InputChanged:Connect(function(input)
		local inputType = input.UserInputType

		if inputType == Enum.UserInputType.MouseMovement or inputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	table.insert(self._connections, changedConnection)

	local moveConnection = UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart

			root.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)
	table.insert(self._connections, moveConnection)

	self.ScreenGui = screenGui
	self.Root = root
	self.Content = content
	self.Parent = guiParent
	self.Theme = Theme

	return self
end

function Window:SetVisible(visible)
	self.ScreenGui.Enabled = visible
end

function Window:Destroy()
	local index

	for index = 1, #self._connections do
		self._connections[index]:Disconnect()
	end

	self._connections = {}
	self.ScreenGui:Destroy()
end

return Window
