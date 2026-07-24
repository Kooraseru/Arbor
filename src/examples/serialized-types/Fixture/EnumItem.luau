-- Serialization/TypesRegistry/EnumItem.luau
--!strict
--!native
local bufReadString = buffer.readstring
local bufReadU32 = buffer.readu32
local bufWriteString = buffer.writestring
local bufWriteU32 = buffer.writeu32

local EnumItemType = {}

local function writeString(buf: buffer, cursor: number, value: string, validator: any): number
	local length = #value
	buf = validator:EnsureSpace(cursor, 4 + length)
	bufWriteU32(buf, cursor, length)
	bufWriteString(buf, cursor + 4, value)
	return cursor + 4 + length
end

local function readString(buf: buffer, cursor: number): (string, number)
	local length = bufReadU32(buf, cursor)
	local value = bufReadString(buf, cursor + 4, length)
	return value, cursor + 4 + length
end

local function getEnumTypeName(enumType: Enum): string
	local enumTypeText = tostring(enumType)
	return enumTypeText:match("%.([^%.]+)$") or enumTypeText
end

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function EnumItemType.Check(value: any): boolean
	return typeof(value) == "EnumItem"
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function EnumItemType.Encode(buf: buffer, cursor: number, value: EnumItem, validator: any): number
	cursor = writeString(buf, cursor, getEnumTypeName(value.EnumType), validator)
	buf = validator.currentWriter.buf
	cursor = writeString(buf, cursor, value.Name, validator)
	return cursor
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function EnumItemType.Decode(buf: buffer, cursor: number, validator: any?): (EnumItem?, number)
	local enumTypeName: string
	enumTypeName, cursor = readString(buf, cursor)

	local enumItemName: string
	enumItemName, cursor = readString(buf, cursor)

	local enumType = Enum[enumTypeName]
	if not enumType then
		warn(`[EnumItemType] Unknown enum type '{enumTypeName}'`)
		return nil, cursor
	end

	local success, enumItem = pcall(function()
		return enumType[enumItemName]
	end)
	if not success or not enumItem then
		warn(`[EnumItemType] Unknown enum item '{enumTypeName}.{enumItemName}'`)
		return nil, cursor
	end

	return enumItem, cursor
end

return EnumItemType
