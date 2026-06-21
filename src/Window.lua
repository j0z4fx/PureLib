local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
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
			navigationIcons[index].ImageColor3 = active and Theme.Panel or Theme.Muted
			navigationLabels[index].TextColor3 = active and Theme.Text or Theme.Muted
		end
	end

	for index = 1, #containers do
		local button = Instance.new("Frame")
		button.Name = "Destination" .. index
		button.LayoutOrder = index
		button.Size = UDim2.new(1, 0, 0, 64)
		button.Active = true
		button.BackgroundTransparency = 1
		button.ZIndex = 3
		button.Parent = navigation

		local indicator = Instance.new("Frame")
		indicator.Name = "ActiveIndicator"
		indicator.AnchorPoint = Vector2.new(0.5, 0.5)
		indicator.Position = UDim2.new(0.5, 0, 0, 20)
		indicator.Size = UDim2.fromOffset(56, 32)
		indicator.BackgroundColor3 = Theme.Accent
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
		table.insert(self._connections, button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				selectPage(index)
			end
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
		local y = window._columnElementY[tabIndex][columnIndex] or 0

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
	self.AddToggle = function(window, tabIndex, columnIndex, text, default, callback)
		local column = assert(window.PageColumns[tabIndex] and window.PageColumns[tabIndex][columnIndex], "Invalid tab or column")
		window._columnElementY[tabIndex] = window._columnElementY[tabIndex] or {}
		local y = window._columnElementY[tabIndex][columnIndex] or 16

		local row = Instance.new("Frame")
		row.Name = "Toggle"
		row.Position = UDim2.fromOffset(0, y)
		row.Size = UDim2.new(1, 0, 0, 48)
		row.BackgroundTransparency = 1
		row.Parent = column

		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, -52, 1, 0)
		label.Font = Enum.Font.Gotham
		label.Text = tostring(text)
		label.TextColor3 = Theme.Text
		label.TextSize = 16
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = row

		local target = Instance.new("Frame")
		target.AnchorPoint = Vector2.new(1, 0.5)
		target.Position = UDim2.fromScale(1, 0.5)
		target.Size = UDim2.fromOffset(48, 48)
		target.Active = true
		target.BackgroundTransparency = 1
		target.Parent = row

		local track = Instance.new("Frame")
		track.AnchorPoint = Vector2.new(0.5, 0.5)
		track.Position = UDim2.fromScale(0.5, 0.5)
		track.Size = UDim2.fromOffset(32, 20)
		track.BorderSizePixel = 0
		track.Parent = target
		corner(track, 10)

		local outline = Instance.new("UIStroke")
		outline.Thickness = 2
		outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		outline.Parent = track

		local handle = Instance.new("Frame")
		handle.BorderSizePixel = 0
		handle.Parent = track
		corner(handle, 8)

		local value = default == true
		local function render(animated)
			local duration = animated and 0.2 or 0
			TweenService:Create(track, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = value and Theme.Accent or Theme.Surface3,
			}):Play()
			TweenService:Create(outline, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = value and Theme.Accent or Theme.BorderHot,
			}):Play()
			TweenService:Create(handle, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = value and UDim2.fromOffset(14, 2) or UDim2.fromOffset(5, 5),
				Size = value and UDim2.fromOffset(16, 16) or UDim2.fromOffset(10, 10),
				BackgroundColor3 = value and Theme.Panel or Theme.BorderHot,
			}):Play()
		end

		local toggle = { Frame = row, Track = track, Handle = handle, Value = value }
		function toggle:SetValue(nextValue, silent)
			value = nextValue == true
			self.Value = value
			render(true)
			if not silent and callback then
				callback(value)
			end
		end

		table.insert(window._connections, target.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				toggle:SetValue(not value)
			end
		end))

		render(false)
		window._columnElementY[tabIndex][columnIndex] = y + 56
		return toggle
	end
	local function addSlider(window, tabIndex, columnIndex, text, options, variant, callback)
		options = options or {}
		local column = assert(window.PageColumns[tabIndex] and window.PageColumns[tabIndex][columnIndex], "Invalid tab or column")
		window._columnElementY[tabIndex] = window._columnElementY[tabIndex] or {}
		local y = window._columnElementY[tabIndex][columnIndex] or 16
		local minimum = tonumber(options.Min) or 0
		local maximum = tonumber(options.Max) or 100
		local step = math.max(tonumber(options.Step) or 1, 0.0001)
		assert(maximum > minimum, "Slider Max must be greater than Min")

		local row = Instance.new("Frame")
		row.Name = variant .. "Slider"
		row.Position = UDim2.fromOffset(0, y)
		row.Size = UDim2.new(1, 0, 0, 72)
		row.BackgroundTransparency = 1
		row.Parent = column

		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, 0, 0, 20)
		label.Font = Enum.Font.Gotham
		label.Text = tostring(text)
		label.TextColor3 = Theme.Text
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = row

		local target = Instance.new("Frame")
		target.Position = UDim2.fromOffset(0, 24)
		target.Size = UDim2.new(1, 0, 0, 48)
		target.Active = true
		target.BackgroundTransparency = 1
		target.Parent = row

		local function segment(name, color)
			local item = Instance.new("Frame")
			item.Name = name
			item.Position = UDim2.fromOffset(0, 16)
			item.Size = UDim2.fromOffset(0, 16)
			item.BackgroundColor3 = color
			item.BorderSizePixel = 0
			item.Parent = target
			corner(item, 8)
			return item
		end

		local left = segment("LeftTrack", Theme.Surface3)
		local active = segment("ActiveTrack", Theme.Accent)
		local right = segment("RightTrack", Theme.Surface3)

		local function makeHandle(name)
			local item = Instance.new("Frame")
			item.Name = name
			item.Size = UDim2.fromOffset(4, 44)
			item.BackgroundColor3 = Theme.Accent
			item.BorderSizePixel = 0
			item.ZIndex = 2
			item.Parent = target
			corner(item, 2)
			return item
		end

		local firstHandle = makeHandle("Handle")
		local secondHandle = variant == "Range" and makeHandle("EndHandle") or nil

		for _, side in ipairs({ 0, 1 }) do
			local stop = Instance.new("Frame")
			stop.Name = "StopIndicator"
			stop.AnchorPoint = Vector2.new(side, 0.5)
			stop.Position = UDim2.new(side, side == 0 and 6 or -6, 0.5, 0)
			stop.Size = UDim2.fromOffset(4, 4)
			stop.BackgroundColor3 = Theme.BorderHot
			stop.BorderSizePixel = 0
			stop.ZIndex = 3
			stop.Visible = variant ~= "Standard" or side == 1
			stop.Parent = target
			corner(stop, 2)
		end

		local function snap(value)
			return math.clamp(minimum + math.floor(((value - minimum) / step) + 0.5) * step, minimum, maximum)
		end

		local value = snap(tonumber(options.Value) or (variant == "Centered" and (minimum + maximum) / 2 or minimum + (maximum - minimum) * 0.5))
		local lower = snap(tonumber(options.Lower) or minimum + (maximum - minimum) * 0.25)
		local upper = snap(tonumber(options.Upper) or minimum + (maximum - minimum) * 0.75)
		if lower > upper then
			lower, upper = upper, lower
		end

		local slider = {
			Frame = row,
			Track = target,
			ActiveTrack = active,
			Handle = firstHandle,
			EndHandle = secondHandle,
			Value = value,
			Lower = lower,
			Upper = upper,
		}

		local function fraction(number)
			return (number - minimum) / (maximum - minimum)
		end

		local function setSegment(item, startX, endX)
			item.Visible = endX > startX
			item.Position = UDim2.fromOffset(startX, 16)
			item.Size = UDim2.fromOffset(math.max(0, endX - startX), 16)
		end

		local function render()
			local width = target.AbsoluteSize.X
			if width <= 0 then
				task.defer(render)
				return
			end

			local x1 = fraction(variant == "Range" and lower or value) * width
			local x2 = fraction(upper) * width
			firstHandle.Position = UDim2.fromOffset(x1 - firstHandle.Size.X.Offset / 2, 2)

			if variant == "Range" then
				secondHandle.Position = UDim2.fromOffset(x2 - secondHandle.Size.X.Offset / 2, 2)
				setSegment(left, 0, math.max(0, x1 - 8))
				setSegment(active, math.min(width, x1 + 8), math.max(0, x2 - 8))
				setSegment(right, math.min(width, x2 + 8), width)
			elseif variant == "Centered" then
				local center = width / 2
				if x1 < center then
					setSegment(left, 0, math.max(0, x1 - 8))
					setSegment(active, math.min(width, x1 + 8), center)
					setSegment(right, center, width)
				else
					setSegment(left, 0, center)
					setSegment(active, center, math.max(0, x1 - 8))
					setSegment(right, math.min(width, x1 + 8), width)
				end
			else
				setSegment(left, 0, math.max(0, x1 - 8))
				left.BackgroundColor3 = Theme.Accent
				active.Visible = false
				setSegment(right, math.min(width, x1 + 8), width)
			end
		end

		local dragging
		local function updateFromX(screenX)
			local normalized = math.clamp((screenX - target.AbsolutePosition.X) / target.AbsoluteSize.X, 0, 1)
			local nextValue = snap(minimum + normalized * (maximum - minimum))

			if variant == "Range" then
				if dragging == "lower" then
					lower = math.min(nextValue, upper)
				else
					upper = math.max(nextValue, lower)
				end
				slider.Lower, slider.Upper = lower, upper
				if callback then callback(lower, upper) end
			else
				value = nextValue
				slider.Value = value
				if callback then callback(value) end
			end
			render()
		end

		local function pressHandle(item, pressed)
			item.Size = UDim2.fromOffset(pressed and 2 or 4, 44)
			render()
		end

		table.insert(window._connections, target.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch
			then return end

			if variant == "Range" then
				local clicked = math.clamp((input.Position.X - target.AbsolutePosition.X) / target.AbsoluteSize.X, 0, 1)
				dragging = math.abs(clicked - fraction(lower)) <= math.abs(clicked - fraction(upper)) and "lower" or "upper"
				pressHandle(dragging == "lower" and firstHandle or secondHandle, true)
			else
				dragging = "value"
				pressHandle(firstHandle, true)
			end
			updateFromX(input.Position.X)
		end))

		table.insert(window._connections, UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch)
			then
				updateFromX(input.Position.X)
			end
		end))

		table.insert(window._connections, UserInputService.InputEnded:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch)
			then
				pressHandle(dragging == "upper" and secondHandle or firstHandle, false)
				dragging = nil
			end
		end))

		function slider:SetValue(nextValue, silent)
			value = snap(tonumber(nextValue) or value)
			self.Value = value
			render()
			if not silent and callback then callback(value) end
		end

		function slider:SetRange(nextLower, nextUpper, silent)
			lower = snap(tonumber(nextLower) or lower)
			upper = snap(tonumber(nextUpper) or upper)
			if lower > upper then lower, upper = upper, lower end
			self.Lower, self.Upper = lower, upper
			render()
			if not silent and callback then callback(lower, upper) end
		end

		table.insert(window._connections, target:GetPropertyChangedSignal("AbsoluteSize"):Connect(render))
		render()
		window._columnElementY[tabIndex][columnIndex] = y + 80
		return slider
	end
	self.AddSlider = function(window, tabIndex, columnIndex, text, options, callback)
		return addSlider(window, tabIndex, columnIndex, text, options, "Standard", callback)
	end
	self.AddCenteredSlider = function(window, tabIndex, columnIndex, text, options, callback)
		return addSlider(window, tabIndex, columnIndex, text, options, "Centered", callback)
	end
	self.AddRangeSlider = function(window, tabIndex, columnIndex, text, options, callback)
		return addSlider(window, tabIndex, columnIndex, text, options, "Range", callback)
	end
	self.NavigationRail = rail
	self.NavigationButtons = navigationButtons
	self.SelectPage = function(_, index)
		selectPage(math.clamp(math.floor(index), 1, #containers))
	end
	self:AddTitle(1, 1, "Demo title")
	self:AddDivider(1, 1)
	self.DemoToggle = self:AddToggle(1, 1, "Demo toggle", false)
	self.DemoSlider = self:AddSlider(1, 2, "Standard slider", { Value = 40 })
	self.DemoCenteredSlider = self:AddCenteredSlider(1, 2, "Centered slider", { Value = 65 })
	self.DemoRangeSlider = self:AddRangeSlider(1, 2, "Range slider", { Lower = 25, Upper = 75 })
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
