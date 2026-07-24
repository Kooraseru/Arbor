-- Serialization/TypesRegistry/Any.luau
--!strict
--!native
local bufWriteU8 = buffer.writeu8
local bufReadU8 = buffer.readu8

local AnyType = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function AnyType.Check(value: any): boolean
	return true
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function AnyType.Encode(buf: buffer, cursor: number, value: any, validator: any): number
	local typeMod = validator:ResolveByValue(value)
	if not typeMod then
		warn(`[AnyType] No type module for value of type '{typeof(value)}'`)
		bufWriteU8(buf, cursor, 0)
		return cursor + 1
	end
	bufWriteU8(buf, cursor, typeMod.Tag)
	return typeMod.Encode(buf, cursor + 1, value, validator)
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function AnyType.Decode(buf: buffer, cursor: number, validator: any): (any, number)
	local tag: number = bufReadU8(buf, cursor)
	local typeMod = validator:GetByTag(tag)
	if not typeMod then
		warn(`[AnyType] No type module for tag {tag}`)
		return nil, cursor + 1
	end
	return typeMod.Decode(buf, cursor + 1, validator)
end

return AnyType
