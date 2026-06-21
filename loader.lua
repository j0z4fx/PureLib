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

local G3_URL = "https://raw.githubusercontent.com/j0z4fx/PureLib/f7898c40a0b834b29595dbd0508105e99afb9517/assets/continuous-corners-p45.png"
local g3Asset

local function getG3Asset()
	if g3Asset ~= nil then
		return g3Asset or nil
	end

	local loadAsset = type(getcustomasset) == "function" and getcustomasset
		or type(getsynasset) == "function" and getsynasset

	if type(writefile) ~= "function" or not loadAsset then
		g3Asset = false
		return nil
	end

	local loaded, asset = pcall(function()
		local path = "PureLib-continuous-corners-p45.png"
		writefile(path, game:HttpGet(G3_URL))
		return loadAsset(path)
	end)

	g3Asset = loaded and asset or false
	return g3Asset or nil
end

local function g3Surface(parent, color, radius, position, size)
	local asset = getG3Asset()

	if asset then
		local surface = Instance.new("ImageLabel")
		surface.BackgroundTransparency = 1
		surface.BorderSizePixel = 0
		surface.Image = asset
		surface.ImageColor3 = color
		surface.Position = position or UDim2.fromOffset(0, 0)
		surface.ScaleType = Enum.ScaleType.Slice
		surface.SliceCenter = Rect.new(48, 48, 80, 80)
		surface.SliceScale = radius / 48
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
	content.Position = UDim2.fromOffset(80, 0)
	content.Size = UDim2.new(1, -80, 1, 0)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ClipsDescendants = true
	content.Parent = root

	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingTop = UDim.new(0, 16)
	contentPadding.PaddingBottom = UDim.new(0, 16)
	contentPadding.PaddingLeft = UDim.new(0, 8)
	contentPadding.PaddingRight = UDim.new(0, 8)
	contentPadding.Parent = content

	local containerColors = {
		Color3.fromRGB(23, 23, 23),
		Color3.fromRGB(23, 23, 23),
		Color3.fromRGB(23, 23, 23),
	}
	local containers = {}
	local pageColumns = {}
	local pageDividers = {}
	local columnCounts = options.Columns or { 3, 2, 1 }

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
		local dividers = {}
		local weights = table.create(count, 1)
		local gap = 8

		for columnIndex = 1, count do
			local column = Instance.new("Frame")
			column.Name = "Column" .. columnIndex
			column.Size = UDim2.fromScale(0, 1)
			column.BackgroundTransparency = 1
			column.BorderSizePixel = 0
			column.Parent = container
			table.insert(columns, column)
		end

		local function updateColumns()
			local available = math.max(0, container.AbsoluteSize.X - gap * (count - 1))
			local totalWeight = 0
			for _, weight in ipairs(weights) do
				totalWeight += weight
			end

			local x = 0
			for columnIndex, column in ipairs(columns) do
				local width = available * weights[columnIndex] / totalWeight
				column.Position = UDim2.fromOffset(x, 0)
				column.Size = UDim2.new(0, width, 1, 0)
				x += width

				if dividers[columnIndex] then
					dividers[columnIndex].Position = UDim2.new(0, x + gap / 2, 0.5, 0)
					x += gap
				end
			end
		end

		for dividerIndex = 1, count - 1 do
			local divider = Instance.new("Frame")
			divider.Name = "Divider" .. dividerIndex
			divider.Active = true
			divider.AnchorPoint = Vector2.new(0.5, 0.5)
			divider.Size = UDim2.new(0, 16, 1, 0)
			divider.BackgroundTransparency = 1
			divider.ZIndex = 5
			divider.Parent = container

			local line = Instance.new("Frame")
			line.AnchorPoint = Vector2.new(0.5, 0.5)
			line.Position = UDim2.fromScale(0.5, 0.5)
			line.Size = UDim2.new(0, 1, 1, 0)
			line.BackgroundColor3 = Theme.Border2
			line.BorderSizePixel = 0
			line.Parent = divider

			local handle = Instance.new("Frame")
			handle.AnchorPoint = Vector2.new(0.5, 0.5)
			handle.Position = UDim2.fromScale(0.5, 0.5)
			handle.Size = UDim2.fromOffset(4, 32)
			handle.BackgroundColor3 = Theme.BorderHot
			handle.BorderSizePixel = 0
			handle.ZIndex = 6
			handle.Parent = divider
			corner(handle, 2)

			local draggingDivider = false
			local startX = 0
			local startLeft = 0
			local startRight = 0

			table.insert(self._connections, divider.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					draggingDivider = true
					for weightIndex, column in ipairs(columns) do
						weights[weightIndex] = column.AbsoluteSize.X
					end
					startX = input.Position.X
					startLeft = columns[dividerIndex].AbsoluteSize.X
					startRight = columns[dividerIndex + 1].AbsoluteSize.X
				end
			end))

			table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
				if draggingDivider
					and (input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch)
				then
					local pairWidth = startLeft + startRight
					local left = math.clamp(startLeft + input.Position.X - startX, 120, pairWidth - 120)
					weights[dividerIndex] = left
					weights[dividerIndex + 1] = pairWidth - left
					updateColumns()
				end
			end))

			table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					draggingDivider = false
				end
			end))

			dividers[dividerIndex] = divider
		end

		table.insert(self._connections, container:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateColumns))
		task.defer(updateColumns)
		pageColumns[index] = columns
		pageDividers[index] = dividers
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
	navigation.Position = UDim2.fromOffset(0, 8)
	navigation.Size = UDim2.new(1, 0, 0, 200)
	navigation.BackgroundTransparency = 1
	navigation.Parent = rail

	local navigationLayout = Instance.new("UIListLayout")
	navigationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	navigationLayout.SortOrder = Enum.SortOrder.LayoutOrder
	navigationLayout.Padding = UDim.new(0, 4)
	navigationLayout.Parent = navigation

	local navigationButtons = {}
	local indicators = {}
	local navigationIcons = {}
	local navigationLabels = {}
	local destinationNames = options.TabNames or { "Inbox", "Outbox", "Favorites" }
	local iconData = {
		{ Url = "rbxasset://textures/u3lntJIKD2kYIeT.png", Offset = Vector2.new(650, 350) },
		{ Url = "rbxasset://textures/u3lntJIKD2kYIeT.png", Offset = Vector2.new(400, 950) },
		{ Url = "rbxasset://textures/u3lntJIKD2kYIeT.png", Offset = Vector2.new(400, 575) },
	}

	local function selectPage(selected)
		for index, container in ipairs(containers) do
			local active = index == selected
			container.Visible = active
			indicators[index].BackgroundTransparency = active and 0 or 1
			navigationIcons[index].ImageColor3 = active and Theme.Text or Theme.Muted
			navigationLabels[index].TextColor3 = active and Theme.Text or Theme.Muted
		end
	end

	for index = 1, #containers do
		local button = Instance.new("TextButton")
		button.Name = "Destination" .. index
		button.LayoutOrder = index
		button.Size = UDim2.new(1, 0, 0, 64)
		button.BackgroundTransparency = 1
		button.Text = ""
		button.ZIndex = 3
		button.Parent = navigation

		local indicator = Instance.new("Frame")
		indicator.Name = "ActiveIndicator"
		indicator.AnchorPoint = Vector2.new(0.5, 0.5)
		indicator.Position = UDim2.new(0.5, 0, 0, 20)
		indicator.Size = UDim2.fromOffset(56, 32)
		indicator.BackgroundColor3 = Theme.Surface3
		indicator.BackgroundTransparency = 1
		indicator.BorderSizePixel = 0
		indicator.ZIndex = 2
		indicator.Parent = button
		corner(indicator, 16)

		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.BackgroundTransparency = 1
		icon.Position = UDim2.new(0.5, 0, 0, 20)
		icon.Size = UDim2.fromOffset(24, 24)
		icon.Image = iconData[index].Url
		icon.ImageColor3 = Theme.Muted
		icon.ImageRectOffset = iconData[index].Offset
		icon.ImageRectSize = Vector2.new(24, 24)
		icon.ZIndex = 4
		icon.Parent = button

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.BackgroundTransparency = 1
		label.Position = UDim2.new(0, 4, 0, 40)
		label.Size = UDim2.new(1, -8, 0, 16)
		label.Font = Enum.Font.GothamMedium
		label.Text = destinationNames[index] or ("Tab " .. index)
		label.TextColor3 = Theme.Muted
		label.TextSize = 12
		label.ZIndex = 4
		label.Parent = button

		table.insert(navigationButtons, button)
		table.insert(indicators, indicator)
		table.insert(navigationIcons, icon)
		table.insert(navigationLabels, label)
		table.insert(self._connections, button.MouseButton1Click:Connect(function()
			selectPage(index)
		end))
	end

	selectPage(1)

	self.ScreenGui = screenGui
	self.Root = root
	self.Content = content
	self.Containers = containers
	self.PageColumns = pageColumns
	self.PageDividers = pageDividers
	self._columnElementY = {}
	self.AddDivider = function(window, tabIndex, columnIndex)
		local column = assert(window.PageColumns[tabIndex] and window.PageColumns[tabIndex][columnIndex], "Invalid tab or column")
		window._columnElementY[tabIndex] = window._columnElementY[tabIndex] or {}
		local y = window._columnElementY[tabIndex][columnIndex] or 16

		local divider = Instance.new("Frame")
		divider.Name = "Divider"
		divider.Position = UDim2.fromOffset(0, y)
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.BackgroundColor3 = Theme.Border2
		divider.BorderSizePixel = 0
		divider.Parent = column

		window._columnElementY[tabIndex][columnIndex] = y + 17
		return divider
	end
	self.AddTitle = function(window, tabIndex, columnIndex, text)
		local column = assert(window.PageColumns[tabIndex] and window.PageColumns[tabIndex][columnIndex], "Invalid tab or column")
		window._columnElementY[tabIndex] = window._columnElementY[tabIndex] or {}
		local y = window._columnElementY[tabIndex][columnIndex] or 16

		local title = Instance.new("Frame")
		title.Name = "Title"
		title.Position = UDim2.fromOffset(0, y)
		title.Size = UDim2.new(1, 0, 0, 20)
		title.BackgroundTransparency = 1
		title.Parent = column

		local line = Instance.new("Frame")
		line.AnchorPoint = Vector2.new(0, 0.5)
		line.Position = UDim2.fromScale(0, 0.5)
		line.Size = UDim2.new(1, 0, 0, 1)
		line.BackgroundColor3 = Theme.Border2
		line.BorderSizePixel = 0
		line.Parent = title

		local label = Instance.new("TextLabel")
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Position = UDim2.fromScale(0.5, 0.5)
		label.AutomaticSize = Enum.AutomaticSize.X
		label.Size = UDim2.fromOffset(0, 20)
		label.BackgroundColor3 = Theme.Surface
		label.BorderSizePixel = 0
		label.Font = Enum.Font.GothamMedium
		label.Text = "  " .. tostring(text) .. "  "
		label.TextColor3 = Theme.Muted
		label.TextSize = 12
		label.ZIndex = 2
		label.Parent = title

		window._columnElementY[tabIndex][columnIndex] = y + 36
		return title
	end
	self.NavigationRail = rail
	self.NavigationButtons = navigationButtons
	self.SelectPage = function(_, index)
		selectPage(math.clamp(math.floor(index), 1, #containers))
	end
	self:AddTitle(1, 1, "Demo title")
	self:AddDivider(1, 1)
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
