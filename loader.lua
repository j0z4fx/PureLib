local AssetService = game:GetService("AssetService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

warn("[PureLib] Loader started")

local FakeLoadDelay = math.max(0, tonumber(fakeLoadDelay) or 0)

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

local G3_SIZE = 512
local g3Image
local g3Content

local function getG3Content()
	if g3Content ~= nil then
		return g3Content or nil
	end

	local loaded, content = pcall(function()
		local image = AssetService:CreateEditableImage({
			Size = Vector2.new(G3_SIZE, G3_SIZE),
		})
		assert(image, "Could not load EditableImage canvas.")

		local pixels = buffer.create(G3_SIZE * G3_SIZE * 4)
		local byteOffset = 0
		local aaRange = 0.015

		for y = 1, G3_SIZE do
			for x = 1, G3_SIZE do
				local nx = (x - G3_SIZE / 2) / (G3_SIZE / 2)
				local ny = (y - G3_SIZE / 2) / (G3_SIZE / 2)
				local value = math.abs(nx) ^ 4.5 + math.abs(ny) ^ 4.5
				local alpha = 0

				if value <= 1 - aaRange then
					alpha = 255
				elseif value < 1 + aaRange then
					local t = (value - (1 - aaRange)) / (aaRange * 2)
					alpha = math.floor((1 - t) * 255)
				end

				buffer.writeu8(pixels, byteOffset, 255)
				buffer.writeu8(pixels, byteOffset + 1, 255)
				buffer.writeu8(pixels, byteOffset + 2, 255)
				buffer.writeu8(pixels, byteOffset + 3, alpha)
				byteOffset += 4
			end
		end

		image:WritePixelsBuffer(Vector2.zero, Vector2.new(G3_SIZE, G3_SIZE), pixels)
		g3Image = image
		return Content.fromObject(image)
	end)

	g3Content = loaded and content or false
	return g3Content or nil
end

local function g3Surface(parent, color, radius, position, size)
	local content = getG3Content()

	if content then
		local surface = Instance.new("ImageLabel")
		surface.BackgroundTransparency = 1
		surface.BorderSizePixel = 0
		surface.ImageContent = content
		surface.ImageColor3 = color
		surface.Position = position or UDim2.fromOffset(0, 0)
		surface.ScaleType = Enum.ScaleType.Stretch
		surface.Size = size or UDim2.fromScale(1, 1)
		surface.Parent = parent
		return surface
	end

	local surface = Instance.new("Frame")
	surface.BackgroundColor3 = color
	surface.BorderSizePixel = 0
	surface.Position = position or UDim2.fromOffset(0, 0)
	surface.Size = size or UDim2.fromScale(1, 1)
	surface.Parent = parent
	corner(surface, radius)
	return surface
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
	card.Size = UDim2.fromOffset(360, 76)
	card.BackgroundTransparency = 1
	card.BorderSizePixel = 0
	card.Parent = screenGui
	g3Surface(card, Theme.Surface, 18)

	local status = Instance.new("TextLabel")
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
	rail.Position = UDim2.fromOffset(16, 52)
	rail.Size = UDim2.new(1, -32, 0, 8)
	rail.BackgroundTransparency = 1
	rail.BorderSizePixel = 0
	rail.Parent = card

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = rail
	corner(fill, 4)

	local track = Instance.new("Frame")
	track.Position = UDim2.fromOffset(4, 0)
	track.Size = UDim2.new(1, -4, 1, 0)
	track.BackgroundColor3 = Theme.Surface3
	track.BorderSizePixel = 0
	track.Parent = rail
	corner(track, 4)

	return {
		ScreenGui = screenGui,
		Set = function(_, text, progress)
			progress = math.clamp(progress, 0, 1)
			local gap = progress > 0 and progress < 1 and 4 or 0
			status.Text = text
			percentage.Text = string.format("%d%%", math.floor(progress * 100 + 0.5))
			fill:TweenSize(
				UDim2.new(progress, -progress * gap, 1, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.3,
				true
			)
			track:TweenPosition(
				UDim2.new(progress, (1 - progress) * gap, 0, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.3,
				true
			)
			track:TweenSize(
				UDim2.new(1 - progress, -(1 - progress) * gap, 1, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.3,
				true
			)
		end,
		Destroy = function()
			statusTween:Cancel()
			screenGui:Destroy()
		end,
	}
end

cleanup()
warn("[PureLib] Previous instances cleaned")
local loader = createLoader()
loader:Set("Previous instances cleaned", 0.25)

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
	root.BackgroundTransparency = 1
	root.BorderSizePixel = 0
	root.Parent = screenGui
	g3Surface(root, Theme.Border, 18)
	g3Surface(root, Theme.Surface, 17, UDim2.fromOffset(1, 1), UDim2.new(1, -2, 1, -2))

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
	local activeLoader = loader
	loader = nil

	if activeLoader then
		window.Root.Visible = false

		task.spawn(function()
			local steps = {
				"Previous instances cleaned",
				"Loader mounted",
				"Components ready",
				"Interface ready",
			}
			local stepDelay = FakeLoadDelay / #steps

			for index, step in ipairs(steps) do
				activeLoader:Set(step, index / #steps)
				if stepDelay > 0 then
					task.wait(stepDelay)
				end
			end

			window.Root.Visible = true
			activeLoader:Destroy()
		end)
	end

	return window
end

warn("[PureLib] Loader ready")
return PureLib
