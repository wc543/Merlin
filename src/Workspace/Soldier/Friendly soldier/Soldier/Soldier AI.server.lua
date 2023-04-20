------Respawn------
local clone = script.Parent:Clone()

------Fix network issues------
while script.Parent.HumanoidRootPart:GetNetworkOwnershipAuto() do
	script.Parent.HumanoidRootPart:SetNetworkOwner(nil)
	wait()
end

------Body Variables------
local myHuman = script.Parent.Humanoid
local myTorso = script.Parent.Torso
local myHead = script.Parent.Head
local myFace = myHead.face
local neck = myTorso.Neck
local headWeld = myTorso["Head Weld"]
local rArm = script.Parent["Right Arm"]
local lArm = script.Parent["Left Arm"]
local lShoulder = myTorso["Left Shoulder"]
local rShoulder = myTorso["Right Shoulder"]
local lArmWeld = myTorso["Left Arm Weld"]
local rArmWeld = myTorso["Right Arm Weld"]
local gyro = script.Parent.HumanoidRootPart.BodyGyro

------M4 Variables------
local m4 = script.Parent.M4
local m4Weld = m4["M4 Weld"]
local barrel = script.Parent.Barrel
local aimer = script.Parent.Aimer
local aimerWeld = aimer["Aimer Weld"]
local fullMag = 30
local mag = fullMag
local flash = barrel.Attachment.Flash

------Knife variables------
local knife = script.Parent.Knife
local knifeWeld = knife["Knife Weld"]

------Grenade variables------
local grenade = script.Parent.Grenade

------Sounds------
local equipSound = m4.Equip
local fireSound = m4.Fire
local reloadSound = m4.Reload
local knifeEquipSound = knife.EquipSound
local knifeAttackSound = knife.AttackSound
local knifeStabSound = knife.StabSound
local hurtSound = myHead.Hurt
local pinSound = grenade.Pin

------Animations------
local stabAnimation = myHuman:LoadAnimation(script.Parent.Stab)
stabAnimation.Priority = Enum.AnimationPriority.Action
local throwAnimation = myHuman:LoadAnimation(script.Parent.ThrowAnimation)
throwAnimation.Priority = Enum.AnimationPriority.Action
throwAnimation.Looped = false
local reloadAnimation = myHuman:LoadAnimation(script.Parent.Reload)
reloadAnimation.Priority = Enum.AnimationPriority.Action

------Status------
local reloading = false
local weaponAimed = false
local weaponCool = true
local m4Equipped = false
local knifeEquipped = false
local grenadeCool = true
local currentTarget = nil
local status = "Idle"
local faces = {Idle = "http://www.roblox.com/asset/?id=26449032", 
	Attacking = "http://www.roblox.com/asset/?id=286688505", 
	Hunting = "http://www.roblox.com/asset/?id=209715003 ", 
	Hurt = "http://www.roblox.com/asset/?id=258192246",
	Dead = "http://www.roblox.com/asset/?id=15426038"}
local gunPointedAt = nil

------Target/Ally Tracking------
local allies = {"Civilian","Military soldier","Special forces troop","Police"}
local potentialTargets = {}
local activeAllies = {}
local team = script.Parent.Settings.Team.Value
local attackPlayers = script.Parent.Settings.AttackPlayers.Value

function spawner(func,...)
	local co = coroutine.wrap(func)
	co(...)
end

function checkDist(part1,part2)
	return (part1.Position - part2.Position).Magnitude
end

function checkSight(target)
	local ray = Ray.new(barrel.Position, (target.Position - barrel.Position).Unit * 200)
	local part,position = workspace:FindPartOnRayWithIgnoreList(ray, {script.Parent})
	local ray2 = Ray.new(myTorso.Position, (target.Position - myTorso.Position).Unit * 200)
	local part2,position2 = workspace:FindPartOnRayWithIgnoreList(ray2, {script.Parent})
	if part and part2 then
		if part:IsDescendantOf(target.Parent) and part2:IsDescendantOf(target.Parent) then
			return true
		end
	end
	return false
end

function updateFace()
	if myFace.Texture ~= faces.Dead and myFace.Texture ~= faces.Hurt then
		myFace.Texture = faces[status]
	end
end

function findTarget()
	local dist = script.Parent.Settings.DetectionRange.Value
	local target = nil
	potentialTargets = {}
	local seeTargets = {}
	for _,v in ipairs(workspace:GetChildren()) do
		
		local human = v:FindFirstChild("Humanoid")
		local torso = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso")
		if human and torso and v ~= script.Parent then
			
			--Check and see if they are on our team, if they are break the loop.
			local targetTeam
			local teammate = false
			if v:FindFirstChild("Team") then
				targetTeam = v.Team.Value
			elseif v:FindFirstChild("Settings") and v.Settings:FindFirstChild("Team") then
				targetTeam = v.Settings.Team.Value			
			end
			if (targetTeam and targetTeam == team) or (not attackPlayers and game.Players:GetPlayerFromCharacter(v)) then
				teammate = true
			end
			
			if (myTorso.Position - torso.Position).magnitude < dist and human.Health > 0 then
				for i,x in ipairs(allies) do
					if x == v.Name or teammate then
						table.insert(activeAllies,torso)
						break
					elseif i == #allies then
						table.insert(potentialTargets,torso)
					end
				end
			end
		end
	end
	if #potentialTargets > 0 then
		for i,v in ipairs(potentialTargets) do
			if checkSight(v) then
				table.insert(seeTargets,v)
			end
		end
		if #seeTargets > 0 then
			for i,v in ipairs(seeTargets) do
				if (myTorso.Position - v.Position).magnitude < dist then
					target = v
					dist = (myTorso.Position - v.Position).magnitude
				end
			end
		else
			for i,v in ipairs(potentialTargets) do
				if (myTorso.Position - v.Position).magnitude < dist then
					target = v
					dist = (myTorso.Position - v.Position).magnitude
				end
			end
		end
	end
	currentTarget = target 
end

function pathToLocation(target)
	local path = game:GetService("PathfindingService"):CreatePath()
	path:ComputeAsync(myTorso.Position, target.Position)
	local waypoints = path:GetWaypoints()
	
	for _,waypoint in ipairs(waypoints) do
		if waypoint.Action == Enum.PathWaypointAction.Jump then
			myHuman.Jump = true
		end
		myHuman:MoveTo(waypoint.Position)
		spawner(function()
			wait(0.5)
			if myHuman.WalkToPoint.Y > myTorso.Position.Y then
				myHuman.Jump = true
			end
		end)
		local moveSuccess = myHuman.MoveToFinished:Wait()
		if not moveSuccess or not target.Parent or (checkDist(myTorso,target) < 180 and checkSight(target)) or currentTarget ~= target then
			break
		end
		if checkDist(target,waypoints[#waypoints]) > 30 then
			pathToLocation(target)
		end
	end
end

function walkRandom()
	local randX = math.random(-100,100)
	local randZ = math.random(-100,100)
	local goal = myTorso.Position + Vector3.new(randX, 0, randZ)
	local path = game:GetService("PathfindingService"):CreatePath()
	path:ComputeAsync(myTorso.Position, goal)
	local waypoints = path:GetWaypoints()
	
	if path.Status == Enum.PathStatus.Success then
		for i,waypoint in ipairs(waypoints) do
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				myHuman.Jump = true
			end
			myHuman:MoveTo(waypoint.Position)
			spawner(function()
				wait(0.5)
				if myHuman.WalkToPoint.Y > myTorso.Position.Y then
					myHuman.Jump = true
				end
			end)
			local moveSuccess = myHuman.MoveToFinished:Wait()
			if not moveSuccess or currentTarget then
				break
			end
		end
	else
		wait(2)
	end
end

function drawM4()
	yieldKnife()
	if m4Equipped == false then
		m4Equipped = true
		equipSound:Play()
		
		--Right Arm Setup
		rShoulder.Part1 = nil
		rArm.CFrame = aimer.CFrame * CFrame.new(1.25,0.05,-0.65) * CFrame.Angles(math.rad(80),math.rad(0),math.rad(-10))
		rArmWeld.Part1 = rArm
		
		--Left Arm Setup 
		lShoulder.Part1 = nil
		lArm.CFrame = aimer.CFrame * CFrame.new(-0.35,0.05,-1.48) * CFrame.Angles(math.rad(84),math.rad(-3),math.rad(28))
		lArmWeld.Part1 = lArm
		
		--M4 Setup
		m4Weld.Part0 = nil
		m4.CFrame = aimer.CFrame * CFrame.new(0.65,0.37,-2.22) * CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))
		m4Weld.Part0 = aimer
	end
end

function yieldM4()
	myHuman.AutoRotate = true 
	gyro.MaxTorque = Vector3.new(0,0,0)
	if weaponAimed == true then
		weaponAimed = false
		resetHead()
	end
	if m4Equipped == true then
		m4Equipped = false
		equipSound:Play()
		
		--Right Arm setup
		rArmWeld.Part1 = nil
		rShoulder.Part1 = rArm
		
		--Left Arm Setup
		lArmWeld.Part1 = nil
		lShoulder.Part1 = lArm
		
		--M4 Setup
		m4Weld.Part0 = nil
		m4.CFrame = myTorso.CFrame * CFrame.new(0,0,0.6) * CFrame.Angles(math.rad(-90),math.rad(-60),math.rad(90))
		m4Weld.Part0 = myTorso
	end
end

function drawKnife()
	if knifeEquipped == false then
		yieldM4()
		knifeEquipSound:Play()
		knifeEquipped = true
		knifeWeld.Part0 = nil
		knife.CFrame = rArm.CFrame * CFrame.new(0,-1,-1) * CFrame.Angles(math.rad(90),math.rad(180),math.rad(180))
		knifeWeld.Part0 = rArm
	end
end

function yieldKnife()
	if knifeEquipped == true then
		knifeEquipped = false
		knifeWeld.Part0 = nil
		knife.CFrame = myTorso.CFrame * CFrame.new(-1,-1,0.5) * CFrame.Angles(math.rad(-65),0,math.rad(180))
		knifeWeld.Part0 = myTorso
	end
end

function aim(target)
	if weaponAimed == false then
		game:GetService("TweenService"):Create(neck,TweenInfo.new(0.5),{C0 = neck.C0 * CFrame.Angles(0,math.rad(-15),0)}):Play()
	end
	
	myHuman.AutoRotate = false
	
	weaponAimed = true

	gyro.CFrame = CFrame.new(myTorso.Position,target.Position)
	gyro.MaxTorque = Vector3.new(0,math.huge,0)
	if not reloading then
		
		local aimCFrame = CFrame.new(aimer.Position,target.Position)
		aimCFrame = aimCFrame - aimCFrame.Position
		local negateCFrame = myTorso.CFrame - myTorso.Position
		local newC0 = CFrame.new(0,0.5,0) * negateCFrame:Inverse() * aimCFrame
		local x,y,z = newC0:ToEulerAnglesXYZ()
		x = math.clamp(x,-0.8,0.8) --So his aiming isn't crazy backwards
		newC0 = CFrame.new(0,0.5,0) * CFrame.fromEulerAnglesXYZ(x,0,0)
		local lookDiff = (newC0.LookVector - aimerWeld.C0.LookVector).Magnitude 
		game:GetService("TweenService"):Create(aimerWeld,TweenInfo.new(lookDiff * 0.2),{C0 = newC0}):Play()
		
		
		local newC0 = CFrame.new(0,1,0) * CFrame.Angles(-1.5 + math.rad(aimer.Orientation.X),math.rad(15),math.rad(180)) ---1.5 - 
		game:GetService("TweenService"):Create(neck,TweenInfo.new(lookDiff * 0.2),{C0 = newC0}):Play()
		wait(lookDiff*0.2)
	end
end


function resetHead()
	game:GetService("TweenService"):Create(neck,TweenInfo.new(0.5),{C0 = CFrame.new(0,1,0) * CFrame.Angles(math.rad(-90),0,math.rad(180))}):Play()
end

function shoot(target)
	if weaponCool == true and reloading == false then
		weaponCool = false
		
		local shot
		if checkDist(target,myTorso) > 60 then
			shot = 1
		else
			shot = 5
		end
		for i = 1, shot do
			wait(0.1)
			mag = mag - 1 
			
			flash:Emit(1)
			local flash = Instance.new("PointLight",barrel)
			flash.Brightness = 3
			game:GetService("Debris"):AddItem(flash,0.1)
			
			local bullet = Instance.new("Part")
			bullet.Size = Vector3.new(0.1,0.1,0.3)
			bullet.BrickColor = BrickColor.new("Gold")
			bullet.Material = Enum.Material.Neon
			bullet.CFrame = barrel.CFrame
			bullet.CanCollide = false
			bullet.Touched:Connect(function(obj)
				if not obj:IsDescendantOf(script.Parent) then 
					local human = obj.Parent:FindFirstChild("Humanoid")
					if human then
						if obj.Name == "Head" then
							human:TakeDamage(100)
						else
							human:TakeDamage(math.random(35,45))
						end
						if human.Health <= 0 then
							if human.RootPart == currentTarget then
							--Update target as soon as we kill the current one
								findTarget()
							end
						end
					end
					bullet:Destroy()
				end
			end)
			bullet.Parent = workspace
			fireSound:Play()
			
			local spread = Vector3.new(math.random(-shot,shot)/100,math.random(-shot,shot)/100,math.random(-shot,shot)/100)
			
			local bv = Instance.new("BodyVelocity",bullet)
			bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
			bv.Velocity = (aimer.CFrame.LookVector + spread) * 300
			
			local s = Instance.new("Sound",bullet)
			s.Volume = 0.7
			s.PlaybackSpeed = 7
			s.Looped = true
			s.SoundId = "rbxasset://sounds/Rocket whoosh 01.wav"
			s:Play()
			
			local a1 = Instance.new("Attachment",bullet)
			a1.Position = Vector3.new(0,0.05,0)
			local a2 = Instance.new("Attachment",bullet)
			a2.Position = Vector3.new(0,-0.05,0)
			
			local t = Instance.new("Trail",bullet)
			t.Attachment0 = a1
			t.Attachment1 = a2
			t.Color = ColorSequence.new(bullet.Color)
			t.WidthScale = NumberSequence.new(0.1,0.01)
			t.Lifetime = 0.3
			
			--TODO ADD KICK
			
			game:GetService("Debris"):AddItem(bullet, 5)
		end
		
		if mag <= 0 then
			reload()
		end
		
		spawner(function()
			wait(1)
			weaponCool = true
		end)
	end
end

function reload()
	if weaponAimed == true then
		resetHead()
		weaponAimed = false
	end
	reloadSound:Play()
	reloading = true
	
	yieldM4()
	m4Weld.Part0 = nil
	m4.CFrame = lArm.CFrame * CFrame.new(0.6,-1.3,0.2) * CFrame.Angles(math.rad(180),0,0)
	m4Weld.Part0 = lArm
	
	reloadAnimation:Play()
	reloadAnimation:AdjustSpeed(3.1)
	reloadAnimation.Stopped:Wait()
	reloading = false 
	mag = fullMag
	drawM4()
end

function stab(target)
	if weaponCool == true then
		weaponCool = false
		
		knifeStabSound:Play()
		knifeAttackSound:Play()
		stabAnimation:Play()
		local human = target.Parent.Humanoid
		human:TakeDamage(math.random(30,50))
		if human.Health <= 0 then
			findTarget()
		end
		
		spawner(function()
			wait(0.5)
			weaponCool = true
		end)
	end
end

function yieldWeapons()
	yieldKnife()
	yieldM4()
	if weaponAimed == true then
		weaponAimed = false 
		resetHead()
	end
end

function checkCluster(target)
	--Check for nearby allies
	for i,v in ipairs(activeAllies) do
		if checkDist(target,v) < 30 then
			return false
		end
	end
	--Check if enemies are paired close together
	for i,v in ipairs(potentialTargets) do
		if v ~= target then
			if checkDist(target,v) < 15 then
				return true
			end
		end
	end
	return false
end

function throwGrenade(target)
	if weaponCool == true and grenadeCool == true then
		weaponCool = false
		grenadeCool = false
		yieldWeapons()
		local g = grenade:Clone()
		g.Boom.PlayOnRemove = true
		g.Parent = workspace
		g.CanCollide = true
		g.CFrame = rArm.CFrame * CFrame.new(0,-1.3,0) * CFrame.Angles(0,0,math.rad(90))
		g:SetNetworkOwner(nil)
		game:GetService("Debris"):AddItem(g,5)
		
		grenade.Transparency = 1
		
		local w = Instance.new("WeldConstraint",g)
		w.Part0 = rArm
		w.Part1 = g
		
		throwAnimation:Play()
		pinSound:Play()
		
		aim(target)
	
		
		wait(0.4)
		
		if myHuman.Health <= 0 then
			return
		end
		
		aim(target)
		
		throwAnimation:Stop()
		
		w.Part1 = nil
		local dist = checkDist(myTorso,target)
		g.Velocity = (myTorso.CFrame.LookVector + Vector3.new(0,1,0)) * Vector3.new(dist,dist*1.5,dist)
		
		--Wait until grenade is thrown before it can be primed
		touched = g.Touched:Connect(function(obj)
			if not obj:IsDescendantOf(script.Parent) then
				touched:Disconnect()
				g.Pin:Play()
				wait(0.5)
				local x = Instance.new("Explosion",workspace)
				x.Position = g.Position
				x.Hit:Connect(function(obj,dist)
					local human = obj.Parent:FindFirstChild("Humanoid")
					if human then
						human:TakeDamage(20 - dist)
						human:ChangeState(Enum.HumanoidStateType.Ragdoll)
					end
				end)
				g:Destroy()
				game:GetService("Debris"):AddItem(x,2)
			end
		end)
		
		local attach0 = g.Attach0
		local attach1 = g.Attach1
		local t = Instance.new("Trail",g)
		t.Attachment0 = attach0
		t.Attachment1 = attach1
		t.Lifetime = 0.5
		t.Color = ColorSequence.new(Color3.fromRGB(150,150,150))
		t.WidthScale = NumberSequence.new(1,0)
		
		spawner(function()
			wait(1)
			weaponCool = true
			wait(5)
			grenadeCool = true
			grenade.Transparency = 0
		end)
	end
end

function movementLoop()
	while myHuman.Health>0 do
		if currentTarget then
			if checkDist(currentTarget,myTorso) > 30 or not checkSight(currentTarget) then
				pathToLocation(currentTarget)
			elseif checkDist(currentTarget,myTorso) > 8 then
				if math.random(0,1) == 1 then
				end
				wait(0.5)
			end
		else
			local randomAction = math.random(4)
			if randomAction == 3 then
				walkRandom()
			elseif randomAction == 2 then
				--print("Look randomly")
			end
			wait(3)
		end
		wait(0.1)
	end
end

function searchTargetLoop()
	while myHuman.Health>0 do
		findTarget()
		wait(3)
	end
end

function aimingLoop()
	while myHuman.Health>0 do
		if currentTarget then
			if checkSight(currentTarget) then
				aim(currentTarget)
				gunPointedAt = currentTarget
			else
				wait(0.5)
			end
		else
			wait(2)
		end
		wait()
	end
end

function attackLoop()
	while myHuman.Health>0 do
		if currentTarget then
			status = "Hunting"
			updateFace()
			if checkSight(currentTarget) then
				status = "Attacking"
				updateFace()
				local distance = checkDist(myTorso,currentTarget)
				if distance > 15 then
					if checkCluster(currentTarget) == true and distance < 180 and distance > 180 and grenadeCool then
						throwGrenade(currentTarget)
					else
						drawM4()
						repeat 
							wait()
						until gunPointedAt == currentTarget
						shoot(currentTarget)
					end
				else
					drawKnife()
					myHuman:MoveTo(currentTarget.Position)
					local canStab = false
					for i,v in pairs(currentTarget.Parent:GetChildren()) do
						if v:IsA("BasePart") and checkDist(v,myTorso) < 7 then
							canStab = true
						end
					end
					if canStab then
						stab(currentTarget)
					end
				end
			else
				if weaponAimed == true then
					weaponAimed = false
					myHuman.AutoRotate = true
					gyro.MaxTorque = Vector3.new(0,0,0)
					resetHead()
					local newC0 = CFrame.new(0,0.5,0) * CFrame.Angles(-0.5,0,0)
					local lookDiff = (newC0.LookVector - aimerWeld.C0.LookVector).Magnitude 
					game:GetService("TweenService"):Create(aimerWeld,TweenInfo.new(lookDiff * 0.2),{C0 = newC0}):Play()
				end
			end
		else
			status = "Idle"
			updateFace()
			yieldWeapons()
			wait(2)
		end
		wait(0.1)
	end
end

function Died()
	yieldM4()
	status = "Dead"
	myFace.Texture = faces.Dead
	for i,v in ipairs(script.Parent:GetDescendants()) do
		if v:IsA("BallSocketConstraint") then
			v.Enabled = true
		elseif v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and v ~= aimer then
			v.CanCollide = false
		elseif v:IsA("Motor6D") then
			v:Destroy()
		end
	end
	if script.Parent.Settings.Respawn.Value then
		wait(script.Parent.Settings.RespawnDelay.Value)
		clone.Parent = script.Parent.Parent
	end
	for i,v in ipairs(script.Parent:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("Decal") then
			game:GetService("TweenService"):Create(v,TweenInfo.new(0.2),{Transparency = 1}):Play()
		end
	end
	wait(0.2)
	script.Parent:Destroy()
end

myHuman.Died:Connect(Died)

local oldHealth = myHuman.Health
local soundSpeeds = {0.9,0.95,1,1.05,1.1}
myHuman.HealthChanged:Connect(function(health)
	if health < oldHealth and hurtSound.IsPlaying == false then
		hurtSound.PlaybackSpeed = soundSpeeds[math.random(#soundSpeeds)]
		hurtSound:Play()
		spawner(function()
			myFace.Texture = faces.Hurt
			wait(1)
			if myFace.Texture == faces.Hurt then
				myFace.Texture = faces[status]
			end
		end)
	end
	oldHealth = health
end)

spawner(searchTargetLoop)
spawner(attackLoop)
spawner(movementLoop)
spawner(aimingLoop)