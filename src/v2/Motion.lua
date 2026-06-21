local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Motion = {}
Motion.__index = Motion

local presets = {
	Control = { stiffness = 220, damping = 13 },
	Navigation = { stiffness = 190, damping = 15 },
	Overlay = { stiffness = 170, damping = 17 },
	Resize = { stiffness = 240, damping = 21 },
}

function Motion.new()
	local self = setmetatable({}, Motion)
	self._motors = {}
	self._connection = RunService.RenderStepped:Connect(function(dt)
		self:_step(math.min(dt, 1 / 30))
	end)
	return self
end

function Motion:_step(dt)
	for motor in pairs(self._motors) do
		local p = motor.preset
		motor.velocity += (motor.goal - motor.value) * p.stiffness * dt
		motor.velocity *= math.exp(-p.damping * dt)
		motor.value += motor.velocity * dt
		if math.abs(motor.goal - motor.value) < 0.001 and math.abs(motor.velocity) < 0.001 then
			motor.value = motor.goal
			motor.velocity = 0
			self._motors[motor] = nil
		end
		motor.write(motor.value)
	end
end

function Motion:motor(initial, write, preset)
	local owner = self
	local motor = {
		value = initial,
		goal = initial,
		velocity = 0,
		write = write,
		preset = presets[preset or "Control"],
	}
	function motor:Set(goal, immediate)
		self.goal = goal
		if immediate then
			self.value = goal
			self.velocity = 0
			write(goal)
		else
			owner._motors[self] = true
		end
	end
	write(initial)
	return motor
end

function Motion:tween(instance, duration, goals, style)
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(duration, style or Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		goals
	)
	tween:Play()
	return tween
end

function Motion:Destroy()
	if self._connection then
		self._connection:Disconnect()
	end
	table.clear(self._motors)
end

return Motion
