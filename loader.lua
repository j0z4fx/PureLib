local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

warn("[PureLib] Loader started")

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

local function guiParents()
	local parents = {}
	local seen = {}

	local function add(parent)
		if parent and not seen[parent] then
			seen[parent] = true
			table.insert(parents, parent)
		end
	end

	if type(gethui) == "function" then
		add(gethui())
	end

	local player = Players.LocalPlayer
	if player then
		add(player:FindFirstChildOfClass("PlayerGui"))
	end

	return parents
end

local function cleanup()
	for _, parent in ipairs(guiParents()) do
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("ScreenGui")
				and (child:GetAttribute("PureLib") == true or child.Name == "PureLib" or child.Name == "PureLibLoader")
			then
				child:Destroy()
			end
		end
	end
end

local function mountGui(screenGui)
	local parents = guiParents()
	local parent = parents[1]

	if not parent then
		local player = Players.LocalPlayer
		assert(player, "PureLib must run on the client")
		parent = player:WaitForChild("PlayerGui")
	end

	screenGui.Parent = parent
	return parent
end

local function corner(parent, radius)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius)
	item.Parent = parent
end

local function createLoader()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PureLibLoader"
	screenGui:SetAttribute("PureLib", true)
	screenGui.DisplayOrder = 101
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	mountGui(screenGui)

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
	rail.Position = UDim2.new(0, 20, 1, -38)
	rail.Size = UDim2.new(1, -40, 0, 6)
	rail.BackgroundColor3 = Theme.Surface2
	rail.BorderSizePixel = 0
	rail.Parent = card
	corner(rail, 3)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = rail
	corner(fill, 3)

	return {
		ScreenGui = screenGui,
		Set = function(_, text, progress)
			status.Text = text
			fill:TweenSize(
				UDim2.fromScale(math.clamp(progress, 0, 1), 1),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.16,
				true
			)
		end,
		Destroy = function()
			screenGui:Destroy()
		end,
	}
end

cleanup()
warn("[PureLib] Previous instances cleaned")
local loader = createLoader()
loader:Set("Loading components", 0.38)

local Window = {}
Window.__index = Window

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
	corner(root, 10)

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Border
	stroke.Thickness = 1
	stroke.Parent = root

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.fromScale(1, 1)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ClipsDescendants = true
	content.Parent = root

	local dragging = false
	local dragStart
	local startPosition
	local dragInput

	table.insert(self._connections, root.InputBegan:Connect(function(input)
		local inputType = input.UserInputType
		if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = root.Position
		end
	end))

	table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
		local inputType = input.UserInputType
		if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	table.insert(self._connections, root.InputChanged:Connect(function(input)
		local inputType = input.UserInputType
		if inputType == Enum.UserInputType.MouseMovement or inputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end))

	table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			root.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end))

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
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end

	self._connections = {}
	self.ScreenGui:Destroy()
end

local PureLib = {
	Theme = Theme,
}

function PureLib:CreateWindow(options)
	warn("[PureLib] Creating window")
	local window = Window.new(options)
	loader:Set("Ready", 1)
	task.delay(0.2, function()
		loader:Destroy()
	end)
	return window
end

warn("[PureLib] Loader ready")
return PureLib
