-- Serialization/TypesRegistry/Vector2.luau
--!strict
--!native

local bufWriteF32 = buffer.writef32
local bufReadF32 = buffer.readf32
local Vector2New = Vector2.new

local Vector2Type = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function Vector2Type.Check(value: any): boolean
	return typeof(value) == "Vector2"
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function Vector2Type.Encode(buf: buffer, cursor: number, value: Vector2, validator: any?): number
	bufWriteF32(buf, cursor, value.X)
	bufWriteF32(buf, cursor + 4, value.Y)
	return cursor + 8
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function Vector2Type.Decode(buf: buffer, cursor: number, validator: any?): (Vector2, number)
	local x: number = bufReadF32(buf, cursor)
	local y: number = bufReadF32(buf, cursor + 4)
	return Vector2New(x, y), cursor + 8
end

return Vector2Type
