-- Serialization/TypesRegistry/Buffer.luau
--!strict
--!native

local BufferType = {}

local bufCreate = buffer.create
local bufCopy = buffer.copy
local bufLen = buffer.len
local bufReadU32 = buffer.readu32
local bufWriteU32 = buffer.writeu32

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function BufferType.Check(value: any): boolean
	return typeof(value) == "buffer"
end

--[[
	Writes a raw buffer as u32 length plus bytes.

	@param buf buffer Destination buffer.
	@param cursor number Write cursor.
	@param value buffer Value to encode.
	@param validator any? Active type registry.
	@return number Cursor after the encoded value.
]]
function BufferType.Encode(buf: buffer, cursor: number, value: buffer, validator: any?): number
	local length = bufLen(value)
	if validator then
		buf = validator:EnsureSpace(cursor, 4 + length)
	end

	bufWriteU32(buf, cursor, length)
	bufCopy(buf, cursor + 4, value, 0, length)
	return cursor + 4 + length
end

--[[
	Reads a raw buffer written by Encode.

	@param buf buffer Source buffer.
	@param cursor number Read cursor.
	@return (buffer, number) Decoded value and next cursor.
]]
function BufferType.Decode(buf: buffer, cursor: number, validator: any?): (buffer, number)
	local length = bufReadU32(buf, cursor)
	local value = bufCreate(length)
	bufCopy(value, 0, buf, cursor + 4, length)
	return value, cursor + 4 + length
end

return BufferType
