local UserInputService = game:GetService("UserInputService")

local Util = require("v2/Util")
local Icons = require("v2/Icons")

local Controls = {}

local function control(owner, frame, options)
	local api = {
		Frame = frame,
		Value = options.Value,
		Disabled = options.Disabled == true,
	}

	function api:GetValue()
		return self.Value
	end

	function api:SetVisible(visible)
		frame.Visible = visible == true
	end

	function api:SetDisabled(disabled)
		self.Disabled = disabled == true
		if frame:IsA("CanvasGroup") then
			frame.GroupTransparency = self.Disabled and 0.62 or 0
		end
	end

	function api:SetLabel(text)
		if self.Label then self.Label.Text = tostring(text) end
	end

	function api:Destroy()
		frame:Destroy()
	end

	api:SetDisabled(api.Disabled)
	return api
end

local function hit(owner, parent, callback)
	local target = Util.new("Frame", {
		Active = true,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 10,
	}, parent)
	Util.connect(owner, target.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			callback(input)
		end
	end)
	return target
end

local function springScale(ctx, frame)
	local scale = Util.new("UIScale", { Scale = 1 }, frame)
	local motor = ctx.Motion:motor(1, function(value)
		scale.Scale = value
	end)
	return function(pressed)
		motor:Set(pressed and 0.94 or 1)
	end
end

local function button(ctx, parent, options, iconOnly)
	local height = 36
	local width = iconOnly and 40 or math.max(72, options.Width or 112)
	local frame = Util.new("CanvasGroup", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(width, 40),
	}, parent)
	local visual = Util.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(iconOnly and 36 or width, height),
		BorderSizePixel = 0,
	}, frame)
	Util.corner(visual, 14)

	local variant = tostring(options.Variant or (iconOnly and "tonal" or "filled")):lower()
	local theme = ctx.Theme
	if variant == "filled" then
		visual.BackgroundColor3 = theme.Accent
	elseif variant == "tonal" then
		visual.BackgroundColor3 = theme.Surface3
	elseif variant == "text" then
		visual.BackgroundTransparency = 1
	elseif variant == "elevated" then
		visual.BackgroundColor3 = theme.Surface2
	else
		visual.BackgroundColor3 = theme.Surface
		Util.stroke(visual, theme.BorderHot, 1)
	end

	local label
	if not iconOnly then
		label = Util.label(visual, options.Label or "Button", theme, 13)
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Position = UDim2.fromScale(0.5, 0.5)
		label.Size = UDim2.new(1, options.Icon and -44 or -24, 1, 0)
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.Font = Enum.Font.GothamMedium
		label.TextColor3 = variant == "filled" and theme.Panel or theme.Text
	end

	if options.Icon then
		local image = Util.new("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = iconOnly and UDim2.fromScale(0.5, 0.5) or UDim2.fromOffset(18, 18),
			Size = UDim2.fromOffset(18, 18),
			ImageColor3 = variant == "filled" and theme.Panel or theme.Text,
		}, visual)
		Icons.apply(image, options.Icon)
	end

	local api = control(ctx.Owner, frame, options)
	api.Label = label
	local press = springScale(ctx, visual)
	Util.connect(ctx.Owner, visual.InputBegan, function(input)
		if api.Disabled then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			press(true)
		end
	end)
	Util.connect(ctx.Owner, visual.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			press(false)
			if not api.Disabled and options.Callback then options.Callback() end
		end
	end)
	visual.Active = true
	return api
end

local function switch(ctx, parent, options)
	local frame = Util.new("CanvasGroup", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
	}, parent)
	local label = Util.label(frame, options.Label or "Switch", ctx.Theme, 14)
	label.Size = UDim2.new(1, -52, 1, 0)

	local track = Util.new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(34, 22),
		BackgroundColor3 = ctx.Theme.Surface3,
		BorderSizePixel = 0,
	}, frame)
	Util.corner(track, 11)
	local outline = Util.stroke(track, ctx.Theme.BorderHot, 2)

	local thumb = Util.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(7, 11),
		Size = UDim2.fromOffset(10, 10),
		BackgroundColor3 = ctx.Theme.BorderHot,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, track)
	Util.corner(thumb, 9)

	local api = control(ctx.Owner, frame, options)
	api.Label, api.Track, api.Thumb = label, track, thumb
	api.Value = options.Value == true

	local position = ctx.Motion:motor(api.Value and 25 or 9, function(value)
		thumb.Position = UDim2.fromOffset(math.round(value), 11)
	end)
	local size = ctx.Motion:motor(api.Value and 16 or 10, function(value)
		local pixel = math.round(value)
		thumb.Size = UDim2.fromOffset(pixel, pixel)
	end)

	local function render(immediate)
		position:Set(api.Value and 25 or 9, immediate)
		size:Set(api.Value and 16 or 10, immediate)
		ctx.Motion:tween(track, immediate and 0 or 0.24, {
			BackgroundColor3 = api.Value and ctx.Theme.Accent or ctx.Theme.Surface3,
		})
		ctx.Motion:tween(thumb, immediate and 0 or 0.24, {
			BackgroundColor3 = api.Value and ctx.Theme.Panel or ctx.Theme.BorderHot,
		})
		outline.Transparency = api.Value and 1 or 0
	end

	function api:SetValue(value, silent)
		self.Value = value == true
		render(false)
		if not silent and options.Callback then options.Callback(self.Value) end
	end

	hit(ctx.Owner, frame, function()
		if not api.Disabled then api:SetValue(not api.Value) end
	end)
	render(true)
	return api
end

local function selection(ctx, parent, options, radio)
	local frame = Util.new("CanvasGroup", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
	}, parent)
	local label = Util.label(frame, options.Label or (radio and "Radio" or "Checkbox"), ctx.Theme, 14)
	label.Position = UDim2.fromOffset(32, 0)
	label.Size = UDim2.new(1, -32, 1, 0)
	local box = Util.new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromOffset(0, 20),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = ctx.Theme.Surface,
		BorderSizePixel = 0,
	}, frame)
	Util.corner(box, radio and 9 or 4)
	local stroke = Util.stroke(box, ctx.Theme.BorderHot, 2)
	local mark = Util.new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamBold,
		Text = radio and "•" or "✓",
		TextColor3 = ctx.Theme.Panel,
		TextSize = radio and 24 or 14,
	}, box)

	local api = control(ctx.Owner, frame, options)
	api.Label, api.Value = label, options.Value == true
	local scale = Util.new("UIScale", { Scale = 1 }, box)
	local motor = ctx.Motion:motor(1, function(value) scale.Scale = value end)
	local function render()
		box.BackgroundColor3 = api.Value and ctx.Theme.Accent or ctx.Theme.Surface
		stroke.Transparency = api.Value and 1 or 0
		mark.Visible = api.Value
		motor.value, motor.velocity = 0.72, 0
		motor:Set(1)
	end
	function api:SetValue(value, silent)
		self.Value = value == true
		render()
		if not silent and options.Callback then options.Callback(self.Value) end
	end
	hit(ctx.Owner, frame, function()
		if not api.Disabled then api:SetValue(radio and true or not api.Value) end
	end)
	render()
	return api
end

local function slider(ctx, parent, options, variant)
	local frame = Util.new("CanvasGroup", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 64),
	}, parent)
	local label = Util.label(frame, options.Label or "Slider", ctx.Theme, 13)
	label.Size = UDim2.new(1, 0, 0, 20)
	local target = Util.new("Frame", {
		Active = true,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 20),
		Size = UDim2.new(1, 0, 0, 40),
	}, frame)
	local base = Util.new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 8),
		BackgroundColor3 = ctx.Theme.Surface3,
		BorderSizePixel = 0,
	}, target)
	Util.corner(base, 4)
	local active = Util.new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = ctx.Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, target)
	Util.corner(active, 4)

	local function thumb(name)
		local item = Util.new("Frame", {
			Name = name,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(16, 16),
			BackgroundColor3 = ctx.Theme.Accent,
			BorderSizePixel = 0,
			ZIndex = 3,
		}, target)
		Util.corner(item, 8)
		return item
	end
	local first = thumb("Handle")
	local second = variant == "range" and thumb("EndHandle") or nil

	local minimum = tonumber(options.Min) or 0
	local maximum = tonumber(options.Max) or 100
	local step = math.max(tonumber(options.Step) or 1, 0.0001)
	assert(maximum > minimum, "Slider Max must be greater than Min")
	local function snap(value)
		return math.clamp(minimum + math.floor(((value - minimum) / step) + 0.5) * step, minimum, maximum)
	end
	local value = snap(tonumber(options.Value) or (minimum + maximum) / 2)
	local lower = snap(tonumber(options.Lower) or minimum + (maximum - minimum) * 0.25)
	local upper = snap(tonumber(options.Upper) or minimum + (maximum - minimum) * 0.75)
	if lower > upper then lower, upper = upper, lower end

	local api = control(ctx.Owner, frame, options)
	api.Label, api.Track, api.ActiveTrack = label, base, active
	api.Handle, api.EndHandle = first, second
	api.Value, api.Lower, api.Upper = value, lower, upper
	local width = 1
	local display1, display2 = variant == "range" and lower or value, upper
	local motor1, motor2
	local function fraction(number)
		return math.clamp((number - minimum) / (maximum - minimum), 0, 1)
	end
	local function draw()
		width = math.max(1, target.AbsoluteSize.X)
		local x1 = math.round(fraction(display1) * width)
		local x2 = math.round(fraction(display2) * width)
		first.Position = UDim2.fromOffset(x1, 20)
		if second then second.Position = UDim2.fromOffset(x2, 20) end
		local startX, endX
		if variant == "range" then
			startX, endX = math.min(x1, x2), math.max(x1, x2)
		elseif variant == "centered" then
			startX, endX = math.min(width / 2, x1), math.max(width / 2, x1)
		else
			startX, endX = 0, x1
		end
		local raw = endX - startX
		active.Visible = raw > 0.5
		if active.Visible then
			local visualWidth = math.max(8, math.round(raw))
			active.Position = UDim2.fromOffset(math.clamp(math.round((startX + endX - visualWidth) / 2), 0, width - visualWidth), 20)
			active.Size = UDim2.fromOffset(visualWidth, 8)
		end
	end
	motor1 = ctx.Motion:motor(display1, function(result) display1 = result; draw() end)
	motor2 = ctx.Motion:motor(display2, function(result) display2 = result; draw() end)

	local dragging
	local function update(screenX)
		local nextValue = snap(minimum + math.clamp((screenX - target.AbsolutePosition.X) / width, 0, 1) * (maximum - minimum))
		if variant == "range" then
			if dragging == "lower" then lower = math.min(nextValue, upper) else upper = math.max(nextValue, lower) end
			api.Lower, api.Upper = lower, upper
			motor1:Set(lower)
			motor2:Set(upper)
			if options.Callback then options.Callback(lower, upper) end
		else
			value, api.Value = nextValue, nextValue
			motor1:Set(value)
			if options.Callback then options.Callback(value) end
		end
	end
	Util.connect(ctx.Owner, target.InputBegan, function(input)
		if api.Disabled then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		if variant == "range" then
			local clicked = minimum + math.clamp((input.Position.X - target.AbsolutePosition.X) / width, 0, 1) * (maximum - minimum)
			dragging = math.abs(clicked - lower) <= math.abs(clicked - upper) and "lower" or "upper"
		else
			dragging = "value"
		end
		update(input.Position.X)
	end)
	Util.connect(ctx.Owner, UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input.Position.X)
		end
	end)
	Util.connect(ctx.Owner, UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = nil end
	end)
	Util.connect(ctx.Owner, target:GetPropertyChangedSignal("AbsoluteSize"), draw)

	function api:SetValue(nextValue, silent)
		value = snap(tonumber(nextValue) or value)
		self.Value = value
		motor1:Set(value)
		if not silent and options.Callback then options.Callback(value) end
	end
	function api:SetRange(nextLower, nextUpper, silent)
		lower, upper = snap(nextLower), snap(nextUpper)
		if lower > upper then lower, upper = upper, lower end
		self.Lower, self.Upper = lower, upper
		motor1:Set(lower)
		motor2:Set(upper)
		if not silent and options.Callback then options.Callback(lower, upper) end
	end
	draw()
	return api
end

local function textField(ctx, parent, options)
	local supporting = options.SupportingText or options.Error
	local frame = Util.new("CanvasGroup", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, supporting and 64 or 48),
	}, parent)
	local field = Util.new("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = options.Variant == "filled" and ctx.Theme.Surface2 or ctx.Theme.Surface,
		BorderSizePixel = 0,
	}, frame)
	Util.corner(field, 8)
	local stroke = Util.stroke(field, options.Error and ctx.Theme.Danger or ctx.Theme.Border2, 1)
	local box = Util.new("TextBox", {
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = options.Placeholder or "",
		PlaceholderColor3 = ctx.Theme.Dim,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 1, 0),
		Text = tostring(options.Value or ""),
		TextColor3 = ctx.Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, field)
	local floating = Util.label(field, options.Label or "", ctx.Theme, 11)
	floating.AutomaticSize = Enum.AutomaticSize.X
	floating.Position = UDim2.fromOffset(10, -7)
	floating.BackgroundColor3 = ctx.Theme.Surface
	floating.Text = " " .. floating.Text .. " "
	floating.Visible = floating.Text ~= "  "
	if supporting then
		local helper = Util.label(frame, options.Error or supporting, ctx.Theme, 11)
		helper.Position = UDim2.fromOffset(12, 46)
		helper.Size = UDim2.new(1, -24, 0, 16)
		helper.TextColor3 = options.Error and ctx.Theme.Danger or ctx.Theme.Dim
	end
	local api = control(ctx.Owner, frame, options)
	api.Label, api.TextBox, api.Value = floating, box, box.Text
	function api:SetValue(value, silent)
		self.Value = tostring(value or "")
		box.Text = self.Value
		if not silent and options.Callback then options.Callback(self.Value) end
	end
	Util.connect(ctx.Owner, box.Focused, function()
		stroke.Color, stroke.Thickness = ctx.Theme.Accent, 2
	end)
	Util.connect(ctx.Owner, box.FocusLost, function(enterPressed)
		stroke.Color, stroke.Thickness = options.Error and ctx.Theme.Danger or ctx.Theme.Border2, 1
		api.Value = box.Text
		if options.Callback then options.Callback(box.Text, enterPressed) end
	end)
	return api
end

local function dropdown(ctx, parent, options)
	local values = options.Values or {}
	local frame = Util.new("CanvasGroup", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 48),
	}, parent)
	local field = Util.new("Frame", {
		Active = true,
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = ctx.Theme.Surface,
		BorderSizePixel = 0,
	}, frame)
	Util.corner(field, 8)
	Util.stroke(field, ctx.Theme.Border2, 1)
	local label = Util.label(field, options.Value or options.Label or "Select", ctx.Theme, 14)
	label.Position = UDim2.fromOffset(12, 0)
	label.Size = UDim2.new(1, -40, 1, 0)
	local arrow = Util.label(field, "⌄", ctx.Theme, 16)
	arrow.Position = UDim2.new(1, -28, 0, 0)
	arrow.Size = UDim2.fromOffset(20, 44)

	local api = control(ctx.Owner, frame, options)
	api.Label, api.Value = label, options.Value
	local popup
	local function close()
		if popup then popup:Destroy(); popup = nil end
	end
	local function open()
		close()
		popup = Util.new("Frame", {
			Position = UDim2.fromOffset(field.AbsolutePosition.X, field.AbsolutePosition.Y + 46),
			Size = UDim2.fromOffset(field.AbsoluteSize.X, math.min(#values * 36 + 8, 188)),
			BackgroundColor3 = ctx.Theme.Surface2,
			BorderSizePixel = 0,
			ZIndex = 60,
		}, ctx.Overlay)
		Util.corner(popup, 10)
		Util.stroke(popup, ctx.Theme.Border, 1)
		local layout = Util.new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, popup)
		Util.new("UIPadding", {
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
		}, popup)
		for _, item in ipairs(values) do
			local option = Util.new("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 34),
				Font = Enum.Font.Gotham,
				Text = "  " .. tostring(item),
				TextColor3 = ctx.Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 61,
			}, popup)
			Util.connect(ctx.Owner, option.Activated, function()
				api:SetValue(item)
				close()
			end)
		end
	end
	function api:SetValue(value, silent)
		self.Value = value
		label.Text = tostring(value)
		if not silent and options.Callback then options.Callback(value) end
	end
	Util.connect(ctx.Owner, field.InputBegan, function(input)
		if api.Disabled then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if popup then close() else open() end
		end
	end)
	api.Close = close
	return api
end

local function keybind(ctx, parent, options)
	local frame = Util.new("CanvasGroup", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
	}, parent)
	local label = Util.label(frame, options.Label or "Keybind", ctx.Theme, 14)
	label.Size = UDim2.new(1, -96, 1, 0)
	local key = Util.new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(84, 30),
		BackgroundColor3 = ctx.Theme.Surface2,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		Text = tostring(options.Value or Enum.KeyCode.Unknown):gsub("Enum.KeyCode.", ""),
		TextColor3 = ctx.Theme.Muted,
		TextSize = 12,
	}, frame)
	Util.corner(key, 8)
	Util.stroke(key, ctx.Theme.Border2, 1)
	local api = control(ctx.Owner, frame, options)
	api.Label, api.Value = label, options.Value or Enum.KeyCode.Unknown
	local listening = false
	hit(ctx.Owner, key, function()
		if not api.Disabled then listening = true; key.Text = "..." end
	end)
	Util.connect(ctx.Owner, UserInputService.InputBegan, function(input, processed)
		if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
			listening = false
			api.Value = input.KeyCode
			key.Text = input.KeyCode.Name
			if options.Callback then options.Callback(input.KeyCode, "changed") end
		elseif not processed and input.KeyCode == api.Value and not api.Disabled and options.Callback then
			options.Callback(api.Value, "pressed")
		end
	end)
	function api:SetValue(value, silent)
		self.Value = value
		key.Text = value.Name
		if not silent and options.Callback then options.Callback(value, "changed") end
	end
	return api
end

local function colorInput(ctx, parent, options)
	local colors = options.Palette or { ctx.Theme.Accent, ctx.Theme.Success, ctx.Theme.Info, ctx.Theme.Warning, ctx.Theme.Danger }
	local frame = Util.new("CanvasGroup", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
	}, parent)
	local label = Util.label(frame, options.Label or "Color", ctx.Theme, 14)
	label.Size = UDim2.new(1, -48, 1, 0)
	local swatch = Util.new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(32, 24),
		BackgroundColor3 = options.Value or colors[1],
		BorderSizePixel = 0,
	}, frame)
	Util.corner(swatch, 8)
	Util.stroke(swatch, ctx.Theme.BorderHot, 1)
	local api = control(ctx.Owner, frame, options)
	api.Label, api.Value = label, swatch.BackgroundColor3
	local index = 1
	function api:SetValue(value, silent)
		assert(typeof(value) == "Color3", "color value must be Color3")
		self.Value, swatch.BackgroundColor3 = value, value
		if not silent and options.Callback then options.Callback(value) end
	end
	hit(ctx.Owner, swatch, function()
		if api.Disabled then return end
		index = index % #colors + 1
		api:SetValue(colors[index])
	end)
	return api
end

local function chip(ctx, parent, options)
	options = table.clone(options)
	options.Variant = options.Variant or "outlined"
	options.Width = options.Width or 96
	local callback = options.Callback
	local api
	options.Callback = function()
		api:SetValue(not api.Value)
	end
	api = button(ctx, parent, options, false)
	api.Value = options.Value == true
	function api:SetValue(value, silent)
		self.Value = value == true
		if not silent and callback then callback(self.Value) end
	end
	return api
end

local function progress(ctx, parent, options)
	local circular = options.Circular == true
	local frame = Util.new("CanvasGroup", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, circular and 40 or 28),
	}, parent)
	local track = Util.new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = circular and UDim2.fromOffset(28, 28) or UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = ctx.Theme.Surface3,
		BorderSizePixel = 0,
	}, frame)
	Util.corner(track, circular and 14 or 3)
	local fill = Util.new("Frame", {
		Size = UDim2.new(math.clamp(options.Value or 0, 0, 1), 0, 1, 0),
		BackgroundColor3 = ctx.Theme.Accent,
		BorderSizePixel = 0,
	}, track)
	Util.corner(fill, circular and 14 or 3)
	local api = control(ctx.Owner, frame, options)
	api.Value = math.clamp(options.Value or 0, 0, 1)
	function api:SetValue(value)
		self.Value = math.clamp(value, 0, 1)
		ctx.Motion:tween(fill, 0.24, { Size = UDim2.new(self.Value, 0, 1, 0) })
	end
	return api
end

local function title(ctx, parent, options, divider)
	local frame = Util.new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, divider and 17 or 28),
	}, parent)
	local line = Util.new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = ctx.Theme.Border2,
		BorderSizePixel = 0,
	}, frame)
	local api = control(ctx.Owner, frame, options)
	if not divider then
		local label = Util.label(frame, options.Label or "Title", ctx.Theme, 12)
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.AutomaticSize = Enum.AutomaticSize.X
		label.Position = UDim2.fromScale(0.5, 0.5)
		label.Size = UDim2.fromOffset(0, 20)
		label.BackgroundColor3 = ctx.Theme.Surface
		label.Text = "  " .. label.Text .. "  "
		label.TextColor3 = ctx.Theme.Muted
		api.Label = label
	end
	return api
end

local function listRow(ctx, parent, options)
	local frame = Util.new("CanvasGroup", {
		BackgroundColor3 = options.Filled and ctx.Theme.Surface2 or ctx.Theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 48),
	}, parent)
	Util.corner(frame, 8)
	local label = Util.label(frame, options.Label or "List item", ctx.Theme, 14)
	label.Position = UDim2.fromOffset(12, options.SupportingText and -7 or 0)
	label.Size = UDim2.new(1, -24, 1, 0)
	if options.SupportingText then
		local support = Util.label(frame, options.SupportingText, ctx.Theme, 11)
		support.Position = UDim2.fromOffset(12, 12)
		support.Size = UDim2.new(1, -24, 1, 0)
		support.TextColor3 = ctx.Theme.Dim
	end
	local api = control(ctx.Owner, frame, options)
	api.Label = label
	if options.Callback then hit(ctx.Owner, frame, function() if not api.Disabled then options.Callback() end end) end
	return api
end

function Controls.create(ctx, parent, kind, options)
	options = options or {}
	kind = tostring(kind):lower()
	if kind == "button" then return button(ctx, parent, options, false) end
	if kind == "iconbutton" or kind == "icon-button" then return button(ctx, parent, options, true) end
	if kind == "switch" or kind == "toggle" then return switch(ctx, parent, options) end
	if kind == "checkbox" then return selection(ctx, parent, options, false) end
	if kind == "radio" then return selection(ctx, parent, options, true) end
	if kind == "slider" then return slider(ctx, parent, options, "standard") end
	if kind == "centeredslider" or kind == "centered-slider" then return slider(ctx, parent, options, "centered") end
	if kind == "rangeslider" or kind == "range-slider" then return slider(ctx, parent, options, "range") end
	if kind == "textfield" or kind == "text-field" then return textField(ctx, parent, options) end
	if kind == "dropdown" or kind == "select" then return dropdown(ctx, parent, options) end
	if kind == "keybind" then return keybind(ctx, parent, options) end
	if kind == "color" or kind == "colorinput" then return colorInput(ctx, parent, options) end
	if kind == "chip" then return chip(ctx, parent, options) end
	if kind == "progress" then return progress(ctx, parent, options) end
	if kind == "title" then return title(ctx, parent, options, false) end
	if kind == "divider" then return title(ctx, parent, options, true) end
	if kind == "list" or kind == "listrow" then return listRow(ctx, parent, options) end
	error("Unknown PureLib control type: " .. tostring(kind), 2)
end

return Controls
