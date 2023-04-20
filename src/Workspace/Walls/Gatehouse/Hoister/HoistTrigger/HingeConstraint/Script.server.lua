local hoist = script.Parent.Parent
local motor = script.Parent
local direction = 1
local state = 0

hoist.ClickDetector.MouseClick:Connect(function()
	if state == -1 then
		direction = 1
	elseif state == 1 then
		direction = -1
	end
	state = state + direction
	
	if state == 0 then
		motor.ActuatorType = Enum.ActuatorType.Servo
		motor.TargetAngle = motor.CurrentAngle
	else
		motor.ActuatorType = Enum.ActuatorType.Motor
		motor.AngularVelocity = state * -2
	end
end)