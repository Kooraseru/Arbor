-- Serialization/TypesRegistry/Boolean.luau
--!strict
--!native

local bufWriteU8 = buffer.writeu8
local bufReadU8 = buffer.readu8

local BooleanType = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function BooleanType.Check(value: any): boolean
	return type(value) == "boolean"
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function BooleanType.Encode(buf: buffer, cursor: number, value: boolean, validator: any?): number
	bufWriteU8(buf, cursor, if value then 1 else 0)
	return cursor + 1
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function BooleanType.Decode(buf: buffer, cursor: number, validator: any?): (boolean, number)
	return bufReadU8(buf, cursor) ~= 0, cursor + 1
end

return BooleanType
