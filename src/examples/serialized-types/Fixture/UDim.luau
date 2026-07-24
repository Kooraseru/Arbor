-- Serialization/TypesRegistry/UDim.luau
--!strict
--!native

local bufWriteF32 = buffer.writef32
local bufReadF32 = buffer.readf32
local bufWriteI32 = buffer.writei32
local bufReadI32 = buffer.readi32
local UDimNew = UDim.new

local UDimType = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function UDimType.Check(value: any): boolean
	return typeof(value) == "UDim"
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function UDimType.Encode(buf: buffer, cursor: number, value: UDim, validator: any?): number
	bufWriteF32(buf, cursor, value.Scale)
	bufWriteI32(buf, cursor + 4, value.Offset)
	return cursor + 8
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function UDimType.Decode(buf: buffer, cursor: number, validator: any?): (UDim, number)
	local scale: number = bufReadF32(buf, cursor)
	local offset: number = bufReadI32(buf, cursor + 4)
	return UDimNew(scale, offset), cursor + 8
end

return UDimType
