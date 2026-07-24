-- Serialization/TypesRegistry/String.luau
--!strict
--!native

local bufWriteU32 = buffer.writeu32
local bufReadU32 = buffer.readu32
local bufWriteString = buffer.writestring
local bufReadString = buffer.readstring

local StringType = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function StringType.Check(value: any): boolean
	return type(value) == "string"
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function StringType.Encode(buf: buffer, cursor: number, value: string, validator: any?): number
	local length: number = #value
	if validator then
		buf = validator:EnsureSpace(cursor, 4 + length)
	end
	bufWriteU32(buf, cursor, length)
	bufWriteString(buf, cursor + 4, value)
	return cursor + 4 + length
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function StringType.Decode(buf: buffer, cursor: number, validator: any?): (string, number)
	local length: number = bufReadU32(buf, cursor)
	local value: string = bufReadString(buf, cursor + 4, length)
	return value, cursor + 4 + length
end

return StringType
