local Player = game.Players.LocalPlayer
local Exp = Player.leaderstats.Exp
local ReqExp = Player.RequiredExp

Exp.Changed:Connect(function(Changed) --Checks to see if Exp has changed
	if Changed then --Runs if Exp has changed
		script.Parent.ExpBar:TweenSize(UDim2.new(Exp.Value / ReqExp.Value, 0, 1, 0))
		--set ExpBar size to Exp player has / ReqExp
	end
end)

while wait()do --Keeps updating ExpValue/ReqExp
	script.Parent.ExpLabel.Text = Exp.Value.." / "..ReqExp.Value --gets current Exp and current ReqExp
end



