-- TypeManager/InstanceTree/ChildrenOfClass.luau
--!strict

--# Types

export type function Of(inst: type, className: type)
	if not inst:is("extern") then
		error("ChildrenOfClass.Of<T, ClassName> expects a Roblox/host extern type for T")
	end

	if not className:is("singleton") then
		error("ChildrenOfClass.Of<T, ClassName> expects ClassName to be a string singleton")
	end

	local class = className:value()
	if type(class) ~= "string" then
		error("ChildrenOfClass.Of<T, ClassName> expects ClassName to be a string singleton")
	end

	local out = types.newtable()

	for key, prop in inst:properties() do
		if key:is("singleton") then
			local name = key:value()
			local childType = prop.read

			if type(name) == "string" and name ~= "Parent" and childType and childType:is(class) then
				out:setproperty(types.singleton(name), childType)
			end
		end
	end

	return out
end

return {}
