name="Humanoid"

robo=script.Parent:clone()

while true do
	wait(10)
	if script.Parent.Humanoid.Health<1 then
		robot=robo:clone()
		robot.Parent=script.Parent.Parent
		robot:makeJoints()
		script.Parent:remove()
	end
end
		


