char = nil
attacking = false
anims = {
equip = "rbxassetid://1394718670";
hit = "rbxassetid://1394720229";
}
script.Parent.Equipped:connect(function()
char = script.Parent.Parent
plr = game:GetService("Players"):GetPlayerFromCharacter(char)
hum = char:FindFirstChildOfClass("Humanoid")
equipanim = Instance.new("Animation",workspace)
equipanim.Name = "Reserved"
equipanim.AnimationId = anims.equip
load = hum:LoadAnimation(equipanim)
load:Play()
equipanim:Destroy()
end)
script.Parent.Activated:connect(function()
char = script.Parent.Parent
plr = game:GetService("Players"):GetPlayerFromCharacter(char)
attacking = true
hum = char:FindFirstChildOfClass("Humanoid")
anim = Instance.new("Animation",workspace)
anim.Name = "Reserved"
anim.AnimationId = anims.hit
load = hum:LoadAnimation(anim)
load:Play()
anim:Destroy()
wait(2)
attacking = false
end)
script.Parent.Handle.Touched:connect(function(hit)
if attacking then
if hit.Parent ~= char then
findhum = hit.Parent:FindFirstChildOfClass("Humanoid")
if findhum then
findhum:TakeDamage(8)
end
wait(2)
end
end
end)