-- Arbor/src/InstanceTree/ChildrenOfClass.luau
--!strict

--# Types

export type function Of(inst: type, classType: type)
	if not inst:is("extern") then
		error("ChildrenOfClass.Of<T, ClassType> expects a Roblox/host extern type for T")
	end

	if not classType:is("extern") then
		error("ChildrenOfClass.Of<T, ClassType> expects ClassType to be a Roblox/host extern type")
	end

	local out = types.newtable()

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
				out:setproperty(types.singleton(name), childType)
			end
		end
	end

	return out
end

return {}
