-- Serialization/TypesRegistry/UDim2.luau
--!strict
--!native

local bufWriteF32 = buffer.writef32
local bufReadF32 = buffer.readf32
local bufWriteI32 = buffer.writei32
local bufReadI32 = buffer.readi32
local UDim2New = UDim2.new

local UDim2Type = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function UDim2Type.Check(value: any): boolean
	return typeof(value) == "UDim2"
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function UDim2Type.Encode(buf: buffer, cursor: number, value: UDim2, validator: any?): number
	bufWriteF32(buf, cursor, value.X.Scale)
	bufWriteI32(buf, cursor + 4, value.X.Offset)
	bufWriteF32(buf, cursor + 8, value.Y.Scale)
	bufWriteI32(buf, cursor + 12, value.Y.Offset)
	return cursor + 16
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function UDim2Type.Decode(buf: buffer, cursor: number, validator: any?): (UDim2, number)
	local xScale: number = bufReadF32(buf, cursor)
	local xOffset: number = bufReadI32(buf, cursor + 4)
	local yScale: number = bufReadF32(buf, cursor + 8)
	local yOffset: number = bufReadI32(buf, cursor + 12)
	return UDim2New(xScale, xOffset, yScale, yOffset), cursor + 16
end

return UDim2Type
