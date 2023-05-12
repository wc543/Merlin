local character = script.Parent
local humanoid = character:WaitForChild("Humanoid") --looks for and returns Humanoid

humanoid.Died:Connect(function() --when humanoid dies, fires(runs) event
	local killed = humanoid:FindFirstChild("creator") --checks if killed 
	if killed then --runs if humanoid is killed
		local player = killed.Value --player that killed npc
		
		local randExp = math.random(5,10) --random Exp between 5 and 10
		
		player.leaderstats.Exp.Value += randExp --adds Exp to current Exp
	end
end)