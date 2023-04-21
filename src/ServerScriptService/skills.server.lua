game.Players.PlayerAdded:Connect(function(Player) 

    local skills = Instance.new("Folder", Player)
	skills.Name = "skills" -- Sets folder name to skills
	
	local health = Instance.new("IntValue", skills)
	health.Name = "Health" --Sets name to Health
	health.Value = 100 --Sets Value of health to 100

    health:GetPropertyChangedSignal("Value"):Connect(function() --Fires event when value changes
        Player.Character.Humanoid.Health = health.Value      --Sets player health equal to new health value
        Player.Character.Humanoid.MaxHealth = health.Value   --Sets player max health equal to new health value

    end)
end)

local skillIncrements = 
{
    Health = 100, --Increase Health by 100
}

game.ReplicatedStorage.onPointAssign.OnServerEvent:Connect(function(Player, skillAssign)

    local skills = Player:FindFirstChild("skills") --Gets player current skills from folder called "skills"

    if skills and skills:FindFirstChild(skillAssign) and skillAssign.Name ~= "skillPoints" then
        
        local skillPoints = skills.SkillPoints --Player current skill points
        local skill = skills[skillAssign]      --Skill that is being upgraded

        if skillPoints.Value > 0 then --Checks to see if player has any skill points
            skillPoints.Value -= 1    --Subtracts a skill point after assigning to health
            skill.Value += skillIncrements[skillAssign] --Gains the Health
        end
    end
end)