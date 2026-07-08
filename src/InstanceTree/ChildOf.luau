-- TypeManager/src/InstanceTree/ChildOf.luau
--!strict

--# Types

export type function Of(inst: type, name: type)
	if not inst:is("extern") then
		error("ChildOf.Of<T, Name> expects a Roblox/host extern type for T")
	end

	if not name:is("singleton") or type(name:value()) ~= "string" then
		error("ChildOf.Of<T, Name> expects Name to be a string singleton")
	end

	local expectedName = name:value()

	for key, prop in inst:properties() do
		if key:is("singleton") and key:value() == expectedName then
			if prop.read and prop.read:is("extern") then
				return prop.read
			end
		end
	end

	return types.never
end

return {}
