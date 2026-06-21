local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Util = require("v2/Util")
local Icons = require("v2/Icons")
local Controls = require("v2/Controls")
local Surface = require("v2/Surface")

local Tab = {}
Tab.__index = Tab

local Window = {}
Window.__index = Window

local function mount(screenGui)
	if type(gethui) == "function" then
		screenGui.Parent = gethui()
	else
		local player = Players.LocalPlayer
		assert(player, "PureLib must run on client")
		screenGui.Parent = player:WaitForChild("PlayerGui")
	end
	return screenGui.Parent
end

local function text(parent, value, theme, size)
	return Util.new("TextLabel", {
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = tostring(value),
		TextColor3 = theme.Text,
		TextSize = size or 13,
	}, parent)
end

function Window.new(options, theme, motion)
	options = options or {}
	local self = setmetatable({
		_connections = {},
		_tabs = {},
		_radioGroups = {},
		Theme = theme,
		Motion = motion,
	}, Window)

	local gui = Util.new("ScreenGui", {
		Name = options.Name or "PureLib",
		DisplayOrder = 100,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, nil)
	gui:SetAttribute("PureLib", true)
	self.Parent = mount(gui)

	local root = Util.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = options.Size or UDim2.fromOffset(800, 450),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, gui)
	Surface(root, theme.Surface, 17, UDim2.fromOffset(1, 1), UDim2.new(1, -2, 1, -2))

	local rail = Util.new("Frame", {
		Size = UDim2.new(0, 80, 1, 0),
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, root)
	local navigation = Util.new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 8),
		Size = UDim2.new(1, 0, 1, -16),
	}, rail)
	Util.new("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, navigation)

	local content = Util.new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(80, 0),
		Size = UDim2.new(1, -80, 1, 0),
	}, root)
	local overlay = Util.new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 50,
	}, gui)

	self.ScreenGui, self.Root, self.Rail = gui, root, rail
	self.Content, self.Overlay = content, overlay
	return self
end

function Window:_context()
	return {
		Owner = self,
		Theme = self.Theme,
		Motion = self.Motion,
		Overlay = self.Overlay,
	}
end

function Window:_select(selected)
	for _, tab in ipairs(self._tabs) do
		local active = tab == selected
		if active then
			tab.Page.Visible = true
			tab.Page.GroupTransparency = 1
			tab.Page.Position = UDim2.fromOffset(12, 0)
			self.Motion:tween(tab.Page, 0.16, { GroupTransparency = 0 }, Enum.EasingStyle.Quad)
			self.Motion:tween(tab.Page, 0.28, { Position = UDim2.fromOffset(0, 0) })
		else
			local page = tab.Page
			self.Motion:tween(page, 0.14, { GroupTransparency = 1 }, Enum.EasingStyle.Quad)
			task.delay(0.15, function()
				if page.GroupTransparency > 0.99 then page.Visible = false end
			end)
		end
		self.Motion:tween(tab.Indicator, 0.28, {
			BackgroundTransparency = active and 0 or 1,
			Size = active and UDim2.fromOffset(56, 32) or UDim2.fromOffset(48, 28),
		})
		self.Motion:tween(tab.Icon, 0.18, {
			ImageColor3 = active and self.Theme.Panel or self.Theme.Muted,
		})
		self.Motion:tween(tab.NavLabel, 0.18, {
			TextColor3 = active and self.Theme.Text or self.Theme.Muted,
		})
	end
	self.SelectedTab = selected
end

function Window:AddTab(options)
	options = options or {}
	local count = math.clamp(math.floor(options.Columns or 1), 1, 3)
	local page = Util.new("CanvasGroup", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = #self._tabs == 0,
		GroupTransparency = #self._tabs == 0 and 0 or 1,
	}, self.Content)
	local columns, dividers = {}, {}
	local gap = 8
	local weights = table.create(count, 1)

	for index = 1, count do
		local column = Util.new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0, 1),
		}, page)
		Util.new("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, column)
		Util.new("UIPadding", {
			PaddingTop = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 16),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
		}, column)
		columns[index] = column
	end

	local function layoutColumns()
		local available = math.max(0, page.AbsoluteSize.X - gap * (count - 1))
		local total = 0
		for _, weight in ipairs(weights) do total += weight end
		local x, used = 0, 0
		for index, column in ipairs(columns) do
			local width = index == count and (available - used)
				or math.round(available * weights[index] / total)
			width = math.max(0, width)
			column.Position = UDim2.fromOffset(x, 0)
			column.Size = UDim2.new(0, width, 1, 0)
			x += width
			used += width
			if dividers[index] then
				dividers[index].Position = UDim2.new(0, x + gap / 2, 0.5, 0)
				x += gap
			end
		end
	end

	for index = 1, count - 1 do
		local divider = Util.new("Frame", {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 1, 0),
			ZIndex = 8,
		}, page)
		local line = Util.new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0, 1, 1, 0),
			BackgroundColor3 = self.Theme.Border2,
			BorderSizePixel = 0,
		}, divider)
		local handle = Util.new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(4, 32),
			BackgroundColor3 = self.Theme.BorderHot,
			BorderSizePixel = 0,
		}, divider)
		Util.corner(handle, 2)
		local dragging, startX, leftStart, rightStart
		Util.connect(self, divider.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				startX = input.Position.X
				leftStart = columns[index].AbsoluteSize.X
				rightStart = columns[index + 1].AbsoluteSize.X
				for i, column in ipairs(columns) do weights[i] = column.AbsoluteSize.X end
			end
		end)
		Util.connect(self, UserInputService.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local pair = leftStart + rightStart
				local goal = math.clamp(leftStart + input.Position.X - startX, 120, pair - 120)
				weights[index], weights[index + 1] = goal, pair - goal
				layoutColumns()
			end
		end)
		Util.connect(self, UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
		end)
		dividers[index] = divider
	end
	Util.connect(self, page:GetPropertyChangedSignal("AbsoluteSize"), layoutColumns)
	task.defer(layoutColumns)

	local nav = Util.new("Frame", {
		Active = true,
		BackgroundTransparency = 1,
		LayoutOrder = #self._tabs + 1,
		Size = UDim2.new(1, 0, 0, 64),
	}, self.Rail:FindFirstChildWhichIsA("Frame"))
	local indicator = Util.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 20),
		Size = UDim2.fromOffset(56, 32),
		BackgroundColor3 = self.Theme.Accent,
		BackgroundTransparency = #self._tabs == 0 and 0 or 1,
		BorderSizePixel = 0,
	}, nav)
	Util.corner(indicator, 16)
	local icon = Util.new("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 20),
		Size = UDim2.fromOffset(22, 22),
		ImageColor3 = #self._tabs == 0 and self.Theme.Panel or self.Theme.Muted,
		ZIndex = 2,
	}, nav)
	Icons.apply(icon, options.Icon or "settings")
	local navLabel = text(nav, options.Name or ("Tab " .. (#self._tabs + 1)), self.Theme, 12)
	navLabel.Position = UDim2.new(0, 4, 0, 40)
	navLabel.Size = UDim2.new(1, -8, 0, 16)
	navLabel.TextColor3 = #self._tabs == 0 and self.Theme.Text or self.Theme.Muted

	local tab = setmetatable({
		Window = self,
		Page = page,
		Columns = columns,
		Indicator = indicator,
		Icon = icon,
		NavLabel = navLabel,
		Name = options.Name,
	}, Tab)
	table.insert(self._tabs, tab)
	Util.connect(self, nav.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self:_select(tab)
		end
	end)
	if #self._tabs == 1 then self.SelectedTab = tab end
	return tab
end

function Tab:AddControl(columnIndex, kind, options)
	local parent = assert(self.Columns[columnIndex], "Invalid PureLib tab column")
	local api = Controls.create(self.Window:_context(), parent, kind, options)
	if tostring(kind):lower() == "radio" and options and options.Group then
		local groups = self.Window._radioGroups
		groups[options.Group] = groups[options.Group] or {}
		table.insert(groups[options.Group], api)
		local original = api.SetValue
		function api:SetValue(value, silent)
			if value then
				for _, sibling in ipairs(groups[options.Group]) do
					if sibling ~= self and sibling.Value then sibling:SetValue(false, true) end
				end
			end
			original(self, value, silent)
		end
	end
	return api
end

function Window:ShowSnackbar(options)
	options = options or {}
	local bar = Util.new("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 24),
		Size = UDim2.fromOffset(math.min(options.Width or 360, 520), 48),
		BackgroundColor3 = self.Theme.Surface3,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		ZIndex = 70,
	}, self.Overlay)
	Util.corner(bar, 10)
	local label = text(bar, options.Text or "", self.Theme, 13)
	label.Position = UDim2.fromOffset(16, 0)
	label.Size = UDim2.new(1, -32, 1, 0)
	self.Motion:tween(bar, 0.28, { Position = UDim2.new(0.5, 0, 1, -16), GroupTransparency = 0 })
	task.delay(options.Duration or 3, function()
		if not bar.Parent then return end
		self.Motion:tween(bar, 0.2, { Position = UDim2.new(0.5, 0, 1, 16), GroupTransparency = 1 })
		task.delay(0.21, function() if bar.Parent then bar:Destroy() end end)
	end)
	return bar
end

function Window:ShowTooltip(textValue, position, duration)
	local tip = Util.new("CanvasGroup", {
		Position = UDim2.fromOffset(position.X, position.Y),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = self.Theme.Surface3,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		ZIndex = 80,
	}, self.Overlay)
	Util.corner(tip, 6)
	Util.new("UIPadding", {
		PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
	}, tip)
	local label = text(tip, textValue, self.Theme, 11)
	label.AutomaticSize = Enum.AutomaticSize.XY
	self.Motion:tween(tip, 0.18, { GroupTransparency = 0 })
	task.delay(duration or 1.5, function()
		if tip.Parent then tip:Destroy() end
	end)
	return tip
end

function Window:ShowDialog(options)
	options = options or {}
	local scrim = Util.new("Frame", {
		Active = true,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.42,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 90,
	}, self.Overlay)
	local dialog = Util.new("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(options.Width or 320, options.Height or 180),
		BackgroundColor3 = self.Theme.Surface2,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		ZIndex = 91,
	}, scrim)
	Util.corner(dialog, 18)
	local scale = Util.new("UIScale", { Scale = 0.88 }, dialog)
	local titleLabel = text(dialog, options.Title or "Dialog", self.Theme, 16)
	titleLabel.Position = UDim2.fromOffset(20, 16)
	titleLabel.Size = UDim2.new(1, -40, 0, 24)
	titleLabel.Font = Enum.Font.GothamMedium
	local body = text(dialog, options.Text or "", self.Theme, 13)
	body.Position = UDim2.fromOffset(20, 48)
	body.Size = UDim2.new(1, -40, 1, -96)
	body.TextColor3 = self.Theme.Muted
	body.TextWrapped = true
	body.TextYAlignment = Enum.TextYAlignment.Top
	self.Motion:tween(dialog, 0.2, { GroupTransparency = 0 }, Enum.EasingStyle.Quad)
	self.Motion:tween(scale, 0.32, { Scale = 1 })
	local function close(result)
		if options.Callback then options.Callback(result) end
		scrim:Destroy()
	end
	Util.connect(self, scrim.InputBegan, function(input)
		if options.Dismissible ~= false and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			close(false)
		end
	end)
	return { Frame = dialog, Close = close }
end

function Window:SetVisible(visible)
	self.ScreenGui.Enabled = visible == true
end

function Window:Destroy()
	for _, connection in ipairs(self._connections) do connection:Disconnect() end
	table.clear(self._connections)
	self.Motion:Destroy()
	self.ScreenGui:Destroy()
end

return Window
