-- TypeManager/InstanceTree/ChildRecord.luau
--!strict

--# Types

export type function Of(inst: type, value: type)
	if not inst:is("extern") then
		error("ChildRecord.Of<T, V> expects a Roblox/host extern type for T")
	end

	local out = types.newtable()

	for key, prop in inst:properties() do
		if key:is("singleton") then
			local name = key:value()
			local looksLikeDirectChild = prop.read and prop.read:is("extern") and prop.write and prop.write:is("extern")

			if type(name) == "string" and name ~= "Parent" and looksLikeDirectChild then
				out:setproperty(types.singleton(name), value)
			end
		end
	end

	return out
end

return {}
