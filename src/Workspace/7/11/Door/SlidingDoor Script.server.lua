active=false
--Activates if the player is close to the door
script.Parent.Sensor.Touched:Connect(function()
	--Sets active to true
	if active==false then
		active=true
		--Plays open fucntion
		script.Parent.Sensor.Open:Play()
		for i=0,10,1 do
			--Opens each door slowly like automatic doors, moving it 0.45 every loop
			script.Parent.Left:SetPrimaryPartCFrame(script.Parent.Left.PrimaryPart.CFrame*CFrame.new(-0.4,0,0))	
			script.Parent.Right:SetPrimaryPartCFrame(script.Parent.Right.PrimaryPart.CFrame*CFrame.new(0.4,0,0))
			wait()
		end
		--Stays open for 1.75 seconds
		wait(1.75)
		--Plays close function
		script.Parent.Sensor.Close:Play()
		for i=0,10,1 do
			--Closes each door slowly, moviinf it 0.45 every loop
			script.Parent.Left:SetPrimaryPartCFrame(script.Parent.Left.PrimaryPart.CFrame*CFrame.new(0.4,0,0))	
			script.Parent.Right:SetPrimaryPartCFrame(script.Parent.Right.PrimaryPart.CFrame*CFrame.new(-0.4,0,0))	
			wait()
		end
		--Waits a little before allowing doors to opened again
		wait(0.25)
		--Sets active to false and waits for sensor to be touched
		active=false
	end	
end)
