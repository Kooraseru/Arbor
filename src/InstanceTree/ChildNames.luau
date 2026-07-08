-- Arbor/src/InstanceTree/ChildNames.luau
--!strict

--# Types

export type function Of(inst: type)
	if not inst:is("extern") then
		error("ChildNames.Of<T> expects a Roblox/host extern type")
	end

	local out = nil

	for key, prop in inst:properties() do
		if key:is("singleton") then
			local name = key:value()
			local looksLikeDirectChild = prop.read and prop.read:is("extern") and prop.write and prop.write:is("extern")

			if type(name) == "string" and name ~= "Parent" and looksLikeDirectChild then
				local singleton = types.singleton(name)
				out = if out then types.unionof(out, singleton) else singleton
			end
		end
	end

	return out or types.never
end

return {}
