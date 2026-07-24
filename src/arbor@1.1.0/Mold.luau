-- Arbor/src/arbor@1.1.0/Mold.luau
--!strict
-- arbor-facade-require Mold "@self/Mold"
-- arbor-facade-type Mold<Schema, First, Second> = Mold.Resolve<Schema, First, Second>

--# Types

export type function Resolve(schema: type, first: type, second: type)
	assert(schema:is("function"))

	local generics = schema:generics()
	local returns = schema:returns()
	local returnHead = returns.head

	if not returnHead or not returnHead[1] then
		return types.never
	end

	local function replacementFor(generic: type): type?
		if generic == generics[1] then
			return first
		end

		if generic == generics[2] then
			return second
		end

		return nil
	end

	local function substitute(value: type): type
		local replacement = replacementFor(value)

		if replacement then
			return replacement
		end

		if value:is("union") then
			local rebuilt = {}

			for _, component in value:components() do
				table.insert(rebuilt, substitute(component))
			end

			return types.unionof(table.unpack(rebuilt))
		end

		if value:is("function") then
			local parameters = value:parameters()
			local nestedReturns = value:returns()
			local functionGenerics = value:generics()

			for _, functionGeneric in functionGenerics do
				if functionGeneric:is("generic") then
					for _, outerGeneric in generics do
						if outerGeneric:is("generic") and functionGeneric:name() == outerGeneric:name() then
							return value
						end
					end
				end
			end

			local parameterHead = nil
			local nestedReturnHead = nil

			if parameters.head then
				parameterHead = {}

				for _, parameter in parameters.head do
					table.insert(parameterHead, substitute(parameter))
				end
			end

			if nestedReturns.head then
				nestedReturnHead = {}

				for _, returnType in nestedReturns.head do
					table.insert(nestedReturnHead, substitute(returnType))
				end
			end

			local parameterTail = if parameters.tail then substitute(parameters.tail) else nil
			local returnTail = if nestedReturns.tail then substitute(nestedReturns.tail) else nil

			return types.newfunction({
				head = parameterHead,
				tail = parameterTail,
			}, {
				head = nestedReturnHead,
				tail = returnTail,
			}, functionGenerics)
		end

		if value:is("table") then
			local rebuilt = types.newtable()
			local readIndexer = value:readindexer()
			local writeIndexer = value:writeindexer()
			local metatable = value:metatable()

			for key, property in value:properties() do
				if property.read then
					rebuilt:setreadproperty(key, substitute(property.read))
				end

				if property.write then
					rebuilt:setwriteproperty(key, substitute(property.write))
				end
			end

			if readIndexer then
				local readResult = substitute(readIndexer.result)
				local writeResult = if writeIndexer then substitute(writeIndexer.result) else readResult

				if writeResult ~= readResult then
					return types.never
				end

				rebuilt:setindexer(substitute(readIndexer.index), readResult)
			elseif writeIndexer then
				return types.never
			end

			if metatable then
				rebuilt:setmetatable(substitute(metatable))
			end

			return rebuilt
		end

		return value
	end

	return substitute(returnHead[1])
end

--# Return

return {}
