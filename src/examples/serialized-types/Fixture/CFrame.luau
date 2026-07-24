-- Serialization/TypesRegistry/CFrame.luau
--!strict
--!native

local bufWriteF32 = buffer.writef32
local bufReadF32 = buffer.readf32
local CFrameNew = CFrame.new

local CFrameType = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function CFrameType.Check(value: any): boolean
	return typeof(value) == "CFrame"
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function CFrameType.Encode(buf: buffer, cursor: number, value: CFrame, validator: any?): number
	local m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34 = value:GetComponents()
	bufWriteF32(buf, cursor, m11)
	bufWriteF32(buf, cursor + 4, m12)
	bufWriteF32(buf, cursor + 8, m13)
	bufWriteF32(buf, cursor + 12, m14)
	bufWriteF32(buf, cursor + 16, m21)
	bufWriteF32(buf, cursor + 20, m22)
	bufWriteF32(buf, cursor + 24, m23)
	bufWriteF32(buf, cursor + 28, m24)
	bufWriteF32(buf, cursor + 32, m31)
	bufWriteF32(buf, cursor + 36, m32)
	bufWriteF32(buf, cursor + 40, m33)
	bufWriteF32(buf, cursor + 44, m34)
	return cursor + 48
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function CFrameType.Decode(buf: buffer, cursor: number, validator: any?): (CFrame, number)
	local c1: number = bufReadF32(buf, cursor)
	local c2: number = bufReadF32(buf, cursor + 4)
	local c3: number = bufReadF32(buf, cursor + 8)
	local c4: number = bufReadF32(buf, cursor + 12)
	local c5: number = bufReadF32(buf, cursor + 16)
	local c6: number = bufReadF32(buf, cursor + 20)
	local c7: number = bufReadF32(buf, cursor + 24)
	local c8: number = bufReadF32(buf, cursor + 28)
	local c9: number = bufReadF32(buf, cursor + 32)
	local c10: number = bufReadF32(buf, cursor + 36)
	local c11: number = bufReadF32(buf, cursor + 40)
	local c12: number = bufReadF32(buf, cursor + 44)
	return CFrameNew(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12), cursor + 48
end

return CFrameType
