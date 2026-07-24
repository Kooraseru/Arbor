-- Serialization/TypesRegistry/Instance.luau
--!strict

local bufWriteU32 = buffer.writeu32
local bufReadU32 = buffer.readu32

local InstanceType = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function InstanceType.Check(value: any): boolean
	return typeof(value) == "Instance"
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function InstanceType.Encode(buf: buffer, cursor: number, value: Instance, validator: any): number
	local networkedObjects = validator:GetNetworkedObjects()
	local id: number = if networkedObjects then networkedObjects.GetId(value) else 0
	bufWriteU32(buf, cursor, id)
	return cursor + 4
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function InstanceType.Decode(buf: buffer, cursor: number, validator: any): (Instance?, number)
	local id: number = bufReadU32(buf, cursor)
	local networkedObjects = validator:GetNetworkedObjects()
	local instance: Instance? = if networkedObjects then networkedObjects.Resolve(id) else nil
	return instance, cursor + 4
end

return InstanceType
