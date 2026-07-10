-- Arbor/src/InstanceTree/ChildNamesOfClass.luau
--!strict

--# Types

export type function Of(inst: type, classType: type)
	if not inst:is("extern") then
		error("ChildNamesOfClass.Of<T, ClassType> expects a Roblox/host extern type for T")
	end

	if not classType:is("extern") then
		error("ChildNamesOfClass.Of<T, ClassType> expects ClassType to be a Roblox/host extern type")
	end

	local out = nil

	for key, prop in inst:properties() do
		if key:is("singleton") then
			local name = key:value()
			local childType = prop.read
			local matchesClass = false

			if childType then
				local current = childType

				while current do
					if current == classType then
						matchesClass = true
						break
					end

					if not current:is("extern") then
						break
					end

					current = current:readparent()
				end
			end

			if type(name) == "string" and name ~= "Parent" and childType and matchesClass then
				local singleton = types.singleton(name)
				out = if out then types.unionof(out, singleton) else singleton
			end
		end
	end

	return out or types.never
end

return {}
