game.Players.PlayerAdded:Connect(function(player)
	local folder = Instance.new("Folder", player)
	folder.Name = player.Name
	--local member = player.Character:FindFirstChild(player.Name)
	--member.CollisionGroup = "Player"
end)
