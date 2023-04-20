local character = script.Parent

function recurse(root,callback,i)
	i= i or 0
	for _,v in pairs(root:GetChildren()) do
		i = i + 1
		callback(i,v)
		
		if #v:GetChildren() > 0 then
			i = recurse(v,callback,i)
		end
	end
	
	return i
end

function ragdollJoint(part0, part1, attachmentName, className, properties)
	attachmentName = attachmentName.."RigAttachment"
	local constraint = Instance.new(className.."Constraint")
	constraint.Attachment0 = part0:FindFirstChild(attachmentName)
	constraint.Attachment1 = part1:FindFirstChild(attachmentName)
	constraint.Name = "RagdollConstraint"..part1.Name
	
	for _,propertyData in next,properties or {} do
		constraint[propertyData[1]] = propertyData[2]
	end
	
	constraint.Parent = character
end

function getAttachment0(attachmentName)
	for _,child in next,character:GetChildren() do
		local attachment = child:FindFirstChild(attachmentName)
		if attachment then
			return attachment
		end
	end
end

character:WaitForChild("Humanoid").Died:connect(function()
	local camera = workspace.CurrentCamera
	if camera.CameraSubject == character.Humanoid then--If developer isn't controlling camera
		camera.CameraSubject = character.UpperTorso
	end

	--Make it so ragdoll can't collide with invisible HRP, but don't let HRP fall through map and be destroyed in process	
	character.HumanoidRootPart.Anchored = true
	character.HumanoidRootPart.CanCollide = false

	--Helps to fix constraint spasms
	recurse(character, function(_,v)
		if v:IsA("Attachment") then
			v.Axis = Vector3.new(0, 1, 0)
			v.SecondaryAxis = Vector3.new(0, 0, 1)
			v.Rotation = Vector3.new(0, 0, 0)
		end
	end)
	
	--Re-attach hats
	for _,child in next,character:GetChildren() do
		if child:IsA("Accoutrement") then
			--Loop through all parts instead of only checking for one to be forwards-compatible in the event
			--ROBLOX implements multi-part accessories
			for _,part in next,child:GetChildren() do
				if part:IsA("BasePart") then
					local attachment1 = part:FindFirstChildOfClass("Attachment")
					local attachment0 = getAttachment0(attachment1.Name)
					if attachment0 and attachment1 then
						--Shouldn't use constraints for this, but have to because of a ROBLOX idiosyncrasy where
						--joints connecting a character are perpetually deleted while the character is dead
						local constraint = Instance.new("HingeConstraint")
						constraint.Attachment0 = attachment0
						constraint.Attachment1 = attachment1
						constraint.LimitsEnabled = true
						constraint.UpperAngle = 0 --Simulate weld by making it difficult for constraint to move
						constraint.LowerAngle = 0
						constraint.Parent = character
					end
				end
			end
		end
	end
	
	ragdollJoint(character.LowerTorso, character.UpperTorso, "Waist", "BallSocket", {
		{"LimitsEnabled",true};
		{"UpperAngle",5};
	})
	ragdollJoint(character.UpperTorso, character.Head, "Neck", "BallSocket", {
		{"LimitsEnabled",true};
		{"UpperAngle",15};
	})
	
	local handProperties = {
		{"LimitsEnabled", true};
		{"UpperAngle",0};
		{"LowerAngle",0};
	}
	ragdollJoint(character.LeftLowerArm, character.LeftHand, "LeftWrist", "Hinge", handProperties)
	ragdollJoint(character.RightLowerArm, character.RightHand, "RightWrist", "Hinge", handProperties)
	
	local shinProperties = {
		{"LimitsEnabled", true};
		{"UpperAngle", 0};
		{"LowerAngle", -75};
	}
	ragdollJoint(character.LeftUpperLeg, character.LeftLowerLeg, "LeftKnee", "Hinge", shinProperties)
	ragdollJoint(character.RightUpperLeg, character.RightLowerLeg, "RightKnee", "Hinge", shinProperties)
	
	local footProperties = {
		{"LimitsEnabled", true};
		{"UpperAngle", 15};
		{"LowerAngle", -45};
	}
	ragdollJoint(character.LeftLowerLeg, character.LeftFoot, "LeftAnkle", "Hinge", footProperties)
	ragdollJoint(character.RightLowerLeg, character.RightFoot, "RightAnkle", "Hinge", footProperties)
	
	--TODO fix ability for socket to turn backwards whenn ConeConstraints are shipped
	ragdollJoint(character.UpperTorso, character.LeftUpperArm, "LeftShoulder", "BallSocket")
	ragdollJoint(character.LeftUpperArm, character.LeftLowerArm, "LeftElbow", "BallSocket")
	ragdollJoint(character.UpperTorso, character.RightUpperArm, "RightShoulder", "BallSocket")
	ragdollJoint(character.RightUpperArm, character.RightLowerArm, "RightElbow", "BallSocket")
	ragdollJoint(character.LowerTorso, character.LeftUpperLeg, "LeftHip", "BallSocket")
	ragdollJoint(character.LowerTorso, character.RightUpperLeg, "RightHip", "BallSocket")
end)