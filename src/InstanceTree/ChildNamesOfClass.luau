-- Arbor/src/InstanceTree/ChildNamesOfClass.luau
--!strict

--# Types

export type function Of(inst: type, className: type)
	if not inst:is("extern") then
		error("ChildNamesOfClass.Of<T, ClassName> expects a Roblox/host extern type for T")
	end

	if not className:is("singleton") then
		error("ChildNamesOfClass.Of<T, ClassName> expects ClassName to be a string singleton")
	end

	local class = className:value()
	if type(class) ~= "string" then
		error("ChildNamesOfClass.Of<T, ClassName> expects ClassName to be a string singleton")
	end

	local out = nil

	for key, prop in inst:properties() do
		if key:is("singleton") then
			local name = key:value()
			local childType = prop.read

			if type(name) == "string" and name ~= "Parent" and childType and childType:is(class) then
				local singleton = types.singleton(name)
				out = if out then types.unionof(out, singleton) else singleton
			end
		end
	end

	return out or types.never
end

return {}
