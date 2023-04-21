game.Players.PlayerAdded:Connect(function(Player) 
	
	local leaderstats = Instance.new("Folder", Player)
	leaderstats.Name = "leaderstats" --Sets Folder name to leaderstats

	local Level = Instance.new("NumberValue", leaderstats)
	Level.Name = "Level" --Sets name to Level
	Level.Value = 1 --Sets Value of level to 1
	
	local Exp = Instance.new("NumberValue", leaderstats)
	Exp.Name = "Exp" --Sets name to Exp	
	Exp.Value = 0 --Sets Value of Exp to 0
	
	local ReqExp = Instance.new("NumberValue", Player)
	ReqExp.Name = "RequiredExp" --Sets name to RequiredExp
	ReqExp.Value = Level.Value * 10 -- Required Experience at level 1
	local multiplier = 0.25

	local character = Player.Character or Player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid")

	Exp.Changed:Connect(function(Changed) --Checks to see if Exp has changed
		if Exp.Value >= ReqExp.Value then --Checks to see if Exp is higher than ReqExp
			                              
			Exp.Value = Exp.Value - ReqExp.Value --Sets new Exp, I subtract by ReqExp so when you level up,
		                                        	--the leftover Exp gets carried over to the next level
			Level.Value += 1 --Adds 1 to Level
			ReqExp.Value += math.floor((10 * multiplier)) --Adds 10 times the multiplier to ReqExp
			multiplier += 0.25

			humanoid.MaxHealth += 25
			humanoid.Health = humanoid.MaxHealth

		end
	end)
end)

