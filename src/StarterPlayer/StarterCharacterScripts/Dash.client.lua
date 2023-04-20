local UIS = game:GetService("UserInputService")

local Character = game.Players.LocalPlayer.Character
local InDash = false
local DashTime = 0.2
local DashSpeed = 100

UIS.InputBegan:Connect(function(Input)
	if Input.KeyCode == Enum.KeyCode.LeftShift or Input.KeyCode == Enum.KeyCode.RightShift then
		if InDash then return end
		InDash = true
		local BodyVelocity = Instance.new("BodyVelocity", Character.HumanoidRootPart)
		BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		BodyVelocity.Velocity = Character.HumanoidRootPart.CFrame.LookVector * DashSpeed
		game.Debris:AddItem(BodyVelocity,DashTime)
		wait(DashTime)
		
		InDash = false 
	end
end)