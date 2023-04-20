local ClickerModule = require(343254562)
local asset = 12775410
local clickEvent = ClickerModule.RemoteEvent
local interactiveParts = {}
local activationDistance = 12

for i, v in pairs(script.Parent:GetChildren()) do
	if v.Name == "Interactive" then
		table.insert(interactiveParts, v)
		local clicker = Instance.new("ClickDetector")
		clicker.Parent = v
		clicker.MaxActivationDistance = activationDistance
	end
end

local function distanceToCharacter(player, part)
	local character = player.Character
	if character then
		local torso = character:FindFirstChild("Torso")
		if torso then
			return((torso.Position - part.Position).magnitude)
		end
	end
	return math.huge
end

clickEvent.OnServerEvent:connect(function(player, part)
	local isPart = false
	for i = 1, #interactiveParts do
		if part == interactiveParts[i] then
			isPart = true
		end
	end
	if isPart and player.Character and distanceToCharacter(player, part) <= activationDistance then
		game:GetService("InsertService"):LoadAsset(asset):GetChildren()[1].Parent = player.Backpack
	end
end)