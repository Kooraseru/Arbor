-- Serialization/TypesRegistry/Table.luau
--!strict
--!native
local bufWriteU8 = buffer.writeu8
local bufReadU8 = buffer.readu8
local bufWriteU32 = buffer.writeu32
local bufReadU32 = buffer.readu32

local TableType = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function TableType.Check(value: any): boolean
	return type(value) == "table"
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function TableType.Encode(buf: buffer, cursor: number, value: { [any]: any }, validator: any): number
	local entries = {}
	local count: number = 0
	for k, v in value do
		local keyType = validator:ResolveByValue(k)
		local valueType = validator:ResolveByValue(v)
		if not keyType then
			warn(`[TableType] Unsupported key type '{typeof(k)}'`)
			continue
		end
		if not valueType then
			warn(`[TableType] Unsupported value type '{typeof(v)}'`)
			continue
		end

		count += 1
		entries[count] = {
			key = k,
			keyType = keyType,
			value = v,
			valueType = valueType,
		}
	end

	buf = validator:EnsureSpace(cursor, 4)
	bufWriteU32(buf, cursor, count)
	cursor += 4

	for i = 1, count do
		local entry = entries[i]
		local keyType = entry.keyType
		buf = validator:EnsureSpace(cursor, 65)
		bufWriteU8(buf, cursor, keyType.Tag)
		cursor = keyType.Encode(buf, cursor + 1, entry.key, validator)
		buf = validator.currentWriter.buf

		local valueType = entry.valueType
		buf = validator:EnsureSpace(cursor, 65)
		bufWriteU8(buf, cursor, valueType.Tag)
		cursor = valueType.Encode(buf, cursor + 1, entry.value, validator)
		buf = validator.currentWriter.buf
	end

	return cursor
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function TableType.Decode(buf: buffer, cursor: number, validator: any): ({ [any]: any }, number)
	local count: number = bufReadU32(buf, cursor)
	cursor += 4

	local result: { [any]: any } = {}
	for _ = 1, count do
		local keyTag: number = bufReadU8(buf, cursor)
		local keyType = validator:GetByTag(keyTag)
		if not keyType then
			warn(`[TableType] Unknown key tag {keyTag}`)
			return result, cursor
		end
		local key, keyCursor = keyType.Decode(buf, cursor + 1, validator)
		cursor = keyCursor

		local valueTag: number = bufReadU8(buf, cursor)
		local valueType = validator:GetByTag(valueTag)
		if not valueType then
			warn(`[TableType] Unknown value tag {valueTag}`)
			return result, cursor
		end
		local value, valueCursor = valueType.Decode(buf, cursor + 1, validator)
		cursor = valueCursor

		result[key] = value
	end

	return result, cursor
end

return TableType
