local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

humanoid.HealthChanged:Connect(function(Damage)
	script.Parent.Size = UDim2.new(Damage / humanoid.MaxHealth, 0, 1, 0)
end)