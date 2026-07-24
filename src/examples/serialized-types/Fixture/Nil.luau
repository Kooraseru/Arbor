-- Serialization/TypesRegistry/Nil.luau
--!strict
--!native

local NilType = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function NilType.Check(value: any): boolean
	return value == nil
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function NilType.Encode(buf: buffer, cursor: number, value: nil, validator: any?): number
	return cursor
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function NilType.Decode(buf: buffer, cursor: number, validator: any?): (nil, number)
	return nil, cursor
end

return NilType
