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

local G3_PNG = "\137\080\078\071\013\010\026\010\000\000\000\013\073\072\068\082\000\000\000\064\000\000\000\064\008\006\000\000\000\170\105\113\222\000\000\002\113\073\068\065\084\120\218\237\155\177\106\020\081\020\134\191\115\118\023\212\198\042\004\193\066\132\045\132\016\108\036\125\108\076\019\201\059\216\228\049\082\153\046\047\224\059\132\088\217\196\062\216\072\008\088\044\136\197\130\132\052\049\098\022\178\051\115\044\230\220\120\051\121\128\117\231\158\031\046\195\050\119\135\249\191\123\238\157\025\184\191\208\145\153\009\160\034\082\251\111\005\094\002\175\128\117\224\057\176\002\060\001\020\120\012\060\100\049\154\001\191\128\006\248\009\092\000\223\129\083\224\011\240\085\068\026\247\049\000\026\017\177\252\002\210\053\159\058\152\217\051\224\029\176\013\188\000\134\044\151\042\224\027\240\017\248\032\034\063\186\030\187\035\175\126\028\153\217\123\051\187\178\187\170\205\172\242\099\109\102\141\183\069\043\221\071\221\185\199\092\087\238\105\148\123\189\173\000\047\123\128\071\192\017\240\058\163\168\222\150\081\141\183\084\189\199\192\091\224\026\064\068\076\210\156\247\246\009\216\004\230\254\039\161\031\050\031\204\017\240\025\120\147\224\104\182\224\237\185\249\027\239\216\023\243\169\210\071\238\109\019\216\115\207\154\166\192\083\096\226\157\180\103\230\187\149\208\120\133\143\069\100\154\230\246\046\240\192\059\244\213\124\170\004\115\175\187\000\234\207\199\029\063\161\244\095\234\094\119\204\108\048\244\151\155\113\207\071\190\091\005\226\158\215\021\216\240\021\191\046\004\130\184\215\033\176\161\192\026\229\106\077\189\020\074\213\088\253\195\134\130\214\128\220\235\138\002\171\005\003\088\213\194\140\223\003\033\102\118\189\192\239\249\069\107\038\102\102\005\087\064\017\111\126\001\032\000\004\128\000\016\000\002\064\000\008\000\001\032\000\004\128\000\016\000\002\064\000\008\000\001\032\000\004\128\000\016\000\002\064\000\008\000\001\032\000\004\128\000\128\210\110\057\047\085\051\005\046\249\183\139\178\020\037\175\151\090\152\241\123\032\020\056\047\184\002\206\149\054\102\082\042\128\011\165\221\037\094\170\038\010\156\021\012\224\076\129\019\218\052\197\160\144\105\096\238\181\002\078\148\054\098\054\241\019\165\000\048\247\124\154\226\050\135\180\027\038\155\002\000\052\238\245\080\068\234\136\204\152\217\064\068\166\192\129\207\141\121\143\071\127\238\030\015\068\100\106\102\131\136\205\121\140\180\241\014\219\180\225\194\020\155\171\150\124\093\072\190\082\108\238\216\061\086\041\071\172\120\130\178\061\200\031\096\011\216\007\126\123\021\104\118\177\058\075\099\254\047\079\013\203\230\118\126\143\233\107\119\232\094\246\129\045\247\120\155\031\046\062\060\045\165\199\231\255\002\010\047\202\027\240\211\216\233\000\000\000\000\073\069\078\068\174\066\096\130"
local g3Asset

local function getG3Asset()
	if g3Asset ~= nil then
		return g3Asset or nil
	end

	local assetLoader = type(getcustomasset) == "function" and getcustomasset
		or type(getsynasset) == "function" and getsynasset

	if type(writefile) ~= "function" or not assetLoader then
		g3Asset = false
		return nil
	end

	local path = "PureLib-continuous-corners.png"
	local wrote = pcall(writefile, path, G3_PNG)
	local loaded, asset = wrote and pcall(assetLoader, path)
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
		surface.SliceCenter = Rect.new(24, 24, 40, 40)
		surface.SliceScale = radius / 24
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
