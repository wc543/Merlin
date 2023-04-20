local Player = game.Players.LocalPlayer 

while wait()do --keeps updating player level
	script.Parent.Text = "Level : "..Player.leaderstats.Level.Value --gets current level
end


