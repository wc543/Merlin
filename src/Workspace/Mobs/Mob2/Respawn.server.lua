while true do --repeats whenever the humanoid dies
	character = script.Parent
	clone = character:Clone() 
	character.Humanoid.Died:wait() --when humanoid dies, wait for respawn
	wait(3) 
	clone.Parent = game.Workspace.Mobs --location of the mob
	script.Parent = clone --clones the humanoid
	character:Destroy() --humanoid dies
end