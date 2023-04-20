local barrier = script.Parent

barrier.Touched:Connect(function(hit)
	if game.Players:FindFirstChild(hit.Parent.Name) or game.Players:FindFirstChild(hit.Parent.Parent.Name) then
		barrier.CanCollide = false
	else
		barrier.CanCollide = true
	end
end)