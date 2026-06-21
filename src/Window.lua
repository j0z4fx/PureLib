local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local g3Surface = require(script.Parent.ContinuousCorner)

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
	root.BackgroundTransparency = 1
	root.BorderSizePixel = 0
	root.Parent = screenGui

	g3Surface(root, Theme.Border, 18)
	g3Surface(root, Theme.Surface, 17, UDim2.fromOffset(1, 1), UDim2.new(1, -2, 1, -2))

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Position = UDim2.fromOffset(80, 0)
	content.Size = UDim2.new(1, -80, 1, 0)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ClipsDescendants = true
	content.Parent = root

	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingTop = UDim.new(0, 16)
	contentPadding.PaddingBottom = UDim.new(0, 16)
	contentPadding.PaddingLeft = UDim.new(0, 16)
	contentPadding.PaddingRight = UDim.new(0, 16)
	contentPadding.Parent = content

	local containerColors = {
		Color3.fromRGB(23, 23, 23),
		Color3.fromRGB(23, 23, 23),
		Color3.fromRGB(23, 23, 23),
	}
	local containers = {}
	local pageColumns = {}
	local columnCounts = options.Columns or { 3, 2, 1 }
	local columnColors = {
		Color3.fromRGB(239, 68, 68),
		Color3.fromRGB(34, 197, 94),
		Color3.fromRGB(59, 130, 246),
		Color3.fromRGB(168, 85, 247),
		Color3.fromRGB(249, 115, 22),
	}

	for index, color in ipairs(containerColors) do
		local container = Instance.new("Frame")
		container.Name = "Container" .. index
		container.Size = UDim2.fromScale(1, 1)
		container.BackgroundColor3 = color
		container.BorderSizePixel = 0
		container.Visible = index == 1
		container.Parent = content
		table.insert(containers, container)

		local count = math.clamp(math.floor(columnCounts[index] or 3), 1, 3)
		local columns = {}
		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 8)
		layout.Parent = container

		for columnIndex = 1, count do
			local column = Instance.new("Frame")
			column.Name = "Column" .. columnIndex
			column.LayoutOrder = columnIndex
			column.Size = UDim2.new(1 / count, -8 * (count - 1) / count, 1, 0)
			column.BackgroundColor3 = columnColors[(index + columnIndex - 2) % #columnColors + 1]
			column.BorderSizePixel = 0
			column.Parent = container
			table.insert(columns, column)
		end

		pageColumns[index] = columns
	end

	local rail = Instance.new("Frame")
	rail.Name = "NavigationRail"
	rail.Size = UDim2.new(0, 80, 1, 0)
	rail.BackgroundTransparency = 1
	rail.BorderSizePixel = 0
	rail.Parent = root
	g3Surface(rail, Theme.Panel, 18)

	local squareRightEdge = Instance.new("Frame")
	squareRightEdge.Position = UDim2.fromOffset(18, 0)
	squareRightEdge.Size = UDim2.new(1, -18, 1, 0)
	squareRightEdge.BackgroundColor3 = Theme.Panel
	squareRightEdge.BorderSizePixel = 0
	squareRightEdge.Parent = rail

	local navigation = Instance.new("Frame")
	navigation.Name = "Destinations"
	navigation.Position = UDim2.fromOffset(0, 24)
	navigation.Size = UDim2.new(1, 0, 0, 152)
	navigation.BackgroundTransparency = 1
	navigation.Parent = rail

	local navigationLayout = Instance.new("UIListLayout")
	navigationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	navigationLayout.SortOrder = Enum.SortOrder.LayoutOrder
	navigationLayout.Padding = UDim.new(0, 4)
	navigationLayout.Parent = navigation

	local navigationButtons = {}
	local indicators = {}
	local navigationLabels = {}
	local iconData = {
		{ Offset = Vector2.new(575, 625) },
		{ Offset = Vector2.new(750, 0) },
		{ Offset = Vector2.new(825, 550) },
	}

	local function selectPage(selected)
		for index, container in ipairs(containers) do
			local active = index == selected
			container.Visible = active
			indicators[index].BackgroundTransparency = active and 0 or 1
			navigationLabels[index].ImageColor3 = active and Theme.Text or Theme.Muted
		end
	end

	for index = 1, #containers do
		local button = Instance.new("TextButton")
		button.Name = "Destination" .. index
		button.LayoutOrder = index
		button.Size = UDim2.new(1, 0, 0, 48)
		button.BackgroundTransparency = 1
		button.Text = ""
		button.ZIndex = 3
		button.Parent = navigation

		local indicator = Instance.new("Frame")
		indicator.Name = "ActiveIndicator"
		indicator.AnchorPoint = Vector2.new(0.5, 0.5)
		indicator.Position = UDim2.fromScale(0.5, 0.5)
		indicator.Size = UDim2.fromOffset(56, 32)
		indicator.BackgroundColor3 = Theme.Surface3
		indicator.BackgroundTransparency = 1
		indicator.BorderSizePixel = 0
		indicator.ZIndex = 2
		indicator.Parent = button
		corner(indicator, 16)

		local label = Instance.new("ImageLabel")
		label.Name = "Icon"
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.BackgroundTransparency = 1
		label.Position = UDim2.fromScale(0.5, 0.5)
		label.Size = UDim2.fromOffset(24, 24)
		label.Image = "rbxasset://textures/Wc7umPTIl.png"
		label.ImageColor3 = Theme.Muted
		label.ImageRectOffset = iconData[index].Offset
		label.ImageRectSize = Vector2.new(24, 24)
		label.ZIndex = 4
		label.Parent = button

		table.insert(navigationButtons, button)
		table.insert(indicators, indicator)
		table.insert(navigationLabels, label)
		table.insert(self._connections, button.MouseButton1Click:Connect(function()
			selectPage(index)
		end))
	end

	selectPage(1)

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
	self.Containers = containers
	self.PageColumns = pageColumns
	self.NavigationRail = rail
	self.NavigationButtons = navigationButtons
	self.SelectPage = function(_, index)
		selectPage(math.clamp(math.floor(index), 1, #containers))
	end
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
