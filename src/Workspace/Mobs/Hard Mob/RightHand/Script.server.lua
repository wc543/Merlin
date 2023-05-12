function onTouched(part)

	local Character = part.Parent:findFirstChild("Humanoid")

	if Character~=nil then

		Character.Health = Character.Health - 5

	end

end



script.Parent.Touched:connect(onTouched)