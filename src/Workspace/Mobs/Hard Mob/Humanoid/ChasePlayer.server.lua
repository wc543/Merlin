local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local humanoid = script.Parent
local root = humanoid.Parent.PrimaryPart

local targetDistance = 200
local stopDistance = 3
local damage = 100
local attackDistance = 5
local attackDelay = 5
local previousAttack = tick()

function findNearestPlayer()
	local playerList = Players:GetPlayers()
	local nearestPlayer = nil
	local distance = nil
	local direction = nil

	for i, player in pairs(playerList) do
		local character = player.Character
		if character then
			local playerDistance = player.Character.PrimaryPart.Position - root.Position
			if not nearestPlayer then
				nearestPlayer = player
				distance = playerDistance.Magnitude
				direction = playerDistance.Unit
			elseif playerDistance.Magnitude < distance then
				nearestPlayer = player
				distance = playerDistance.Magnitude
				direction = playerDistance.Unit
			end
		end
	end
	
	return nearestPlayer, distance, direction
end

RunService.Heartbeat:Connect(function()
	local nearestPlayer, distance, direction = findNearestPlayer()
	if nearestPlayer then
		if distance <= targetDistance and distance >= stopDistance then
			humanoid:Move(direction)
		else
			humanoid:Move(Vector3.new())
		end
		
		if distance <= attackDistance and tick() - previousAttack >= attackDelay then
			previousAttack = tick()
			nearestPlayer.Character.Humanoid:TakeDamage(damage)
		end
	end
end)