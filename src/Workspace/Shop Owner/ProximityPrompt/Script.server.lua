script.Parent.Triggered:Connect(function(player)
	game:GetService("ReplicatedStorage"):WaitForChild("DialogueRemote"):FireClient(player, "Would you like to see my wares?","Sindri", "Right this way.")
end)