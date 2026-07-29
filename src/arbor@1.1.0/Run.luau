-- Arbor/src/arbor@1.1.0/Logic/Run.luau
--!strict
-- arbor-facade-require Run "@self/Run"
-- arbor-facade-type Run<Molded> = Run.Resolve<Molded>

--# Types

export type function Resolve(molded: type)
	if not molded:is("table") then
		return types.never
	end

	local function matchesClass(childType: type?, classType: type): boolean
		if not childType then
			return false
		end

		local current = childType

		while current do
			if current == classType then
				return true
			end

			if not current:is("extern") then
				return false
			end

			current = current:readparent()
		end

		return false
	end

	local function isChildProperty(name: unknown, read: type?, write: type?): boolean
		if type(name) ~= "string" or name == "Parent" then
			return false
		end

		if not read or not write or read ~= write then
			return false
		end

		return read:is("extern")
	end

	local function directChildOf(instance: type, parent: type): boolean
		if not parent:is("extern") then
			return false
		end

		for key, property in parent:properties() do
			local read = property.read
			local write = property.write

			if key:is("singleton") and isChildProperty(key:value(), read, write) and read == instance then
				return true
			end
		end

		return false
	end

	local function descendantOf(instance: type, ancestor: type, visited: { [type]: boolean }?): boolean
		if directChildOf(instance, ancestor) then
			return true
		end

		if not ancestor:is("extern") then
			return false
		end

		local seen = visited or {}

		if seen[ancestor] then
			return false
		end

		seen[ancestor] = true

		for key, property in ancestor:properties() do
			local read = property.read
			local write = property.write

			if key:is("singleton") and isChildProperty(key:value(), read, write) and read and descendantOf(instance, read, seen) then
				return true
			end
		end

		return false
	end

	local function propertyAllowed(name: unknown, read: type?, write: type?, externOnly: type?, exclude: type?, whereClass: type?): boolean
		if type(name) ~= "string" then
			return false
		end

		if exclude and exclude:is("singleton") and name == exclude:value() then
			return false
		end

		if externOnly and externOnly:is("singleton") and externOnly:value() == true then
			if not isChildProperty(name, read, write) then
				return false
			end
		end

		if whereClass and not matchesClass(read, whereClass) then
			return false
		end

		return true
	end

	local function readPropertySource(marker: type, label: string): type
		if not marker:is("table") then
			error(`{label} marker must be a table type`)
		end

		local source = marker:readproperty(types.singleton("source")) or marker:readproperty(types.singleton("of"))

		if not source then
			error(`{label} requires source`)
		end

		if not source:is("extern") then
			error(`{label} source must be a Roblox/host extern type`)
		end

		return source
	end

	local chain = molded:readproperty(types.singleton("chain"))

	if chain then
		if not chain:is("table") then
			error("chain must be a table type")
		end

		local externChildren = chain:readproperty(types.singleton("ExternChildren"))
		local externIsAncestorOf = chain:readproperty(types.singleton("ExternIsAncestorOf"))
		local externIsDescendantOf = chain:readproperty(types.singleton("ExternIsDescendantOf"))
		local externIsDirectChildOf = chain:readproperty(types.singleton("ExternIsDirectChildOf"))
		local dropName = chain:readproperty(types.singleton("DropName"))
		local keepExtern = chain:readproperty(types.singleton("KeepExtern"))
		local keepClass = chain:readproperty(types.singleton("KeepClass"))
		local toNames = chain:readproperty(types.singleton("ToNames"))
		local toRecord = chain:readproperty(types.singleton("ToRecord"))
		local returnCheck = chain:readproperty(types.singleton("ReturnCheck"))
		local returnOnPass = chain:readproperty(types.singleton("ReturnOnPass"))
		local neverOnEmpty = chain:readproperty(types.singleton("NeverOnEmpty"))

		if externIsAncestorOf then
			if not externIsAncestorOf:is("table") then
				error("ExternIsAncestorOf parameters must be a table type")
			end

			local instance = externIsAncestorOf:readproperty(types.singleton("instance"))
			local descendant = externIsAncestorOf:readproperty(types.singleton("descendant"))

			if not instance or not descendant or not instance:is("extern") or not descendant:is("extern") then
				return types.never
			end

			local passed = descendantOf(descendant, instance)

			if returnCheck then
				return types.singleton(passed)
			end

			if returnOnPass and passed then
				if not returnOnPass:is("table") then
					error("ReturnOnPass parameters must be a table type")
				end

				return returnOnPass:readproperty(types.singleton("value")) or types.never
			end

			return types.never
		end

		if externIsDescendantOf then
			if not externIsDescendantOf:is("table") then
				error("ExternIsDescendantOf parameters must be a table type")
			end

			local instance = externIsDescendantOf:readproperty(types.singleton("instance"))
			local ancestor = externIsDescendantOf:readproperty(types.singleton("ancestor"))

			if not instance or not ancestor or not instance:is("extern") or not ancestor:is("extern") then
				return types.never
			end

			local passed = descendantOf(instance, ancestor)

			if returnCheck then
				return types.singleton(passed)
			end

			if returnOnPass and passed then
				if not returnOnPass:is("table") then
					error("ReturnOnPass parameters must be a table type")
				end

				return returnOnPass:readproperty(types.singleton("value")) or types.never
			end

			return types.never
		end

		if externIsDirectChildOf then
			if not externIsDirectChildOf:is("table") then
				error("ExternIsDirectChildOf parameters must be a table type")
			end

			local instance = externIsDirectChildOf:readproperty(types.singleton("instance"))
			local parent = externIsDirectChildOf:readproperty(types.singleton("parent"))

			if not instance or not parent or not instance:is("extern") or not parent:is("extern") then
				return types.never
			end

			local passed = directChildOf(instance, parent)

			if returnCheck then
				return types.singleton(passed)
			end

			if returnOnPass and passed then
				if not returnOnPass:is("table") then
					error("ReturnOnPass parameters must be a table type")
				end

				return returnOnPass:readproperty(types.singleton("value")) or types.never
			end

			return types.never
		end

		if not externChildren then
			return types.never
		end

		local source = readPropertySource(externChildren, "ExternChildren")
		local exclude = nil
		local whereClass = nil
		local externOnly = nil

		if dropName then
			if not dropName:is("table") then
				error("DropName parameters must be a table type")
			end

			exclude = dropName:readproperty(types.singleton("name"))
		end

		if keepExtern then
			externOnly = types.singleton(true)
		end

		if keepClass then
			if not keepClass:is("table") then
				error("KeepClass parameters must be a table type")
			end

			whereClass = keepClass:readproperty(types.singleton("class"))
		end

		if toNames then
			local out = nil

			for key, property in source:properties() do
				if key:is("singleton") then
					local name = key:value()

					if propertyAllowed(name, property.read, property.write, externOnly, exclude, whereClass) then
						local singleton = types.singleton(name)
						out = if out then types.unionof(out, singleton) else singleton
					end
				end
			end

			if out then
				return out
			end

			if neverOnEmpty then
				return types.never
			end
		end

		if toRecord then
			if not toRecord:is("table") then
				error("ToRecord parameters must be a table type")
			end

			local value = toRecord:readproperty(types.singleton("value"))
			local readValue = toRecord:readproperty(types.singleton("ReadValue"))
			local out = types.newtable()

			if not value and not readValue then
				return types.never
			end

			for key, property in source:properties() do
				if key:is("singleton") then
					local name = key:value()

					if propertyAllowed(name, property.read, property.write, externOnly, exclude, whereClass) then
						local propertyValue = if readValue then property.read else value

						if propertyValue then
							out:setproperty(types.singleton(name), propertyValue)
						end
					end
				end
			end

			return out
		end

		return types.never
	end

	local propertyContains = molded:readproperty(types.singleton("propertyContains"))

	if propertyContains then
		local source = readPropertySource(propertyContains, "propertyContains")
		local value = propertyContains:readproperty(types.singleton("value"))
		local result = propertyContains:readproperty(types.singleton("result"))

		if not value or not result then
			return types.never
		end

		for _, property in source:properties() do
			local read = property.read
			local write = property.write

			if read and write and read == value and write == value then
				return result
			end
		end

		return types.never
	end

	local propertyOf = molded:readproperty(types.singleton("propertyOf"))

	if propertyOf then
		if not propertyOf:is("table") then
			error("propertyOf args must be a table type")
		end

		local source = propertyOf:readproperty(types.singleton("Parent"))
		local name = propertyOf:readproperty(types.singleton("Name"))
		local mode = propertyOf:readproperty(types.singleton("Mode")) or types.singleton("checked")

		if not source or not source:is("extern") then
			error("propertyOf args require Parent to be a Roblox/host extern type")
		end

		if not name or not name:is("singleton") or type(name:value()) ~= "string" then
			error("propertyOf requires name to be a string singleton")
		end

		if not mode:is("singleton") or type(mode:value()) ~= "string" then
			error("propertyOf mode must be a string singleton when provided")
		end

		local modeValue = mode:value()

		if modeValue ~= "checked" and modeValue ~= "optional" and modeValue ~= "required" then
			error("propertyOf mode must be \"checked\", \"optional\", or \"required\"")
		end

		local property = nil

		for key, candidate in source:properties() do
			if key == name and isChildProperty(name:value(), candidate.read, candidate.write) then
				property = candidate.read
				break
			end
		end

		if property then
			return property
		end

		if modeValue == "optional" then
			return types.singleton(nil)
		end

		if modeValue == "required" then
			error(`Child "{name:value()}" does not exist on source`)
		end

		return types.never
	end

	local propertyMap = molded:readproperty(types.singleton("propertyMap"))

	if propertyMap then
		if not propertyMap:is("table") then
			error("propertyMap args must be a table type")
		end

		local source = propertyMap:readproperty(types.singleton("Parent"))
		local value = propertyMap:readproperty(types.singleton("Value"))
		local readValue = propertyMap:readproperty(types.singleton("ReadValue"))
		local externOnly = types.singleton(true)
		local exclude = types.singleton("Parent")
		local whereClass = propertyMap:readproperty(types.singleton("whereClass"))

		if not source or not source:is("extern") then
			error("propertyMap args require Parent to be a Roblox/host extern type")
		end

		if not value and not readValue then
			return types.never
		end

		local out = types.newtable()

		for key, property in source:properties() do
			if key:is("singleton") then
				local name = key:value()

				if propertyAllowed(name, property.read, property.write, externOnly, exclude, whereClass) then
					local propertyValue = if readValue then property.read else value

					if propertyValue then
						out:setproperty(types.singleton(name), propertyValue)
					end
				end
			end
		end

		return out
	end

	local propertyNames = molded:readproperty(types.singleton("propertyNames"))

	if propertyNames then
		local source = readPropertySource(propertyNames, "propertyNames")
		local externOnly = propertyNames:readproperty(types.singleton("externOnly"))
		local exclude = propertyNames:readproperty(types.singleton("exclude"))
		local whereClass = propertyNames:readproperty(types.singleton("whereClass"))
		local out = nil

		for key, property in source:properties() do
			if key:is("singleton") then
				local name = key:value()

				if propertyAllowed(name, property.read, property.write, externOnly, exclude, whereClass) then
					local singleton = types.singleton(name)
					out = if out then types.unionof(out, singleton) else singleton
				end
			end
		end

		return out or types.never
	end

	return types.never
end

--# Return

return {}
