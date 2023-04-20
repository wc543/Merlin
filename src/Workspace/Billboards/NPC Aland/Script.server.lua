local messages = {"Hello player", "Welcome to the game", "This is a story game"}
script.Parent.ClickDetector.MouseClick:Connect(function(plr)
	plr.PlayerGui.NpcChatGui.Enabled = true
	for i, v in pairs(messages) do
		for i = 1, string.len(v) do wait(0.025)
			plr.PlayerGui.NpcChatGui.NpcText.Text = string.sub(v, 1, i)
		end
		wait (string.len(v)/10)
	end
	plr.PlayerGui.NpcChatGui.Enabled = false
end)
