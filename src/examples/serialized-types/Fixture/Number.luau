-- Serialization/TypesRegistry/Number.luau
--!strict
--!native

local bufWriteF64 = buffer.writef64
local bufReadF64 = buffer.readf64

local NumberType = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function NumberType.Check(value: any): boolean
	return type(value) == "number"
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function NumberType.Encode(buf: buffer, cursor: number, value: number, validator: any?): number
	bufWriteF64(buf, cursor, value)
	return cursor + 8
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function NumberType.Decode(buf: buffer, cursor: number, validator: any?): (number, number)
	return bufReadF64(buf, cursor), cursor + 8
end

return NumberType
