-- Serialization/TypesRegistry/Color3.luau
--!strict
--!native

local bufWriteF32 = buffer.writef32
local bufReadF32 = buffer.readf32
local Color3New = Color3.new

local Color3Type = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function Color3Type.Check(value: any): boolean
	return typeof(value) == "Color3"
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function Color3Type.Encode(buf: buffer, cursor: number, value: Color3, validator: any?): number
	bufWriteF32(buf, cursor, value.R)
	bufWriteF32(buf, cursor + 4, value.G)
	bufWriteF32(buf, cursor + 8, value.B)
	return cursor + 12
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function Color3Type.Decode(buf: buffer, cursor: number, validator: any?): (Color3, number)
	local r: number = bufReadF32(buf, cursor)
	local g: number = bufReadF32(buf, cursor + 4)
	local b: number = bufReadF32(buf, cursor + 8)
	return Color3New(r, g, b), cursor + 12
end

return Color3Type
