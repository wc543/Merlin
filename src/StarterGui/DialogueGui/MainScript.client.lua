local remote = game:GetService("ReplicatedStorage"):WaitForChild("DialogueRemote")
local frame = script.Parent:WaitForChild("Frame")

remote.OnClientEvent:Connect(function(dialogue, personName, yesAnswer)
	script.Parent.Enabled = true
	frame:WaitForChild("DialogueText").Text = dialogue
	frame:WaitForChild("PersonName").Text = personName
	
	frame:WaitForChild("No").MouseButton1Down:Connect(function()
		script.Parent.Enabled = false
	end)
	
	frame:WaitForChild("Yes").MouseButton1Down:Connect(function()
		frame:WaitForChild("DialogueText").Text = yesAnswer
		frame:WaitForChild("Yes").Visible = false
		frame:WaitForChild("No").Visible = false
		wait(2)
		script.Parent.Enabled = false
		frame:WaitForChild("Yes").Visible = true
		frame:WaitForChild("No").Visible = true
	end)
end)