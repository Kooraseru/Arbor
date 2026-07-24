-- Serialization/TypesRegistry/Vector3.luau
--!strict
--!native

local bufWriteF32 = buffer.writef32
local bufReadF32 = buffer.readf32
local Vector3New = Vector3.new

local Vector3Type = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function Vector3Type.Check(value: any): boolean
	return typeof(value) == "Vector3"
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function Vector3Type.Encode(buf: buffer, cursor: number, value: Vector3, validator: any?): number
	bufWriteF32(buf, cursor, value.X)
	bufWriteF32(buf, cursor + 4, value.Y)
	bufWriteF32(buf, cursor + 8, value.Z)
	return cursor + 12
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function Vector3Type.Decode(buf: buffer, cursor: number, validator: any?): (Vector3, number)
	local x: number = bufReadF32(buf, cursor)
	local y: number = bufReadF32(buf, cursor + 4)
	local z: number = bufReadF32(buf, cursor + 8)
	return Vector3New(x, y, z), cursor + 12
end

return Vector3Type
