-- Serialization/TypesRegistry/Player.luau
--!strict

local Players = game:GetService("Players")

-- you may wonder why tf using floats for this
-- Roblox does not provide i64 buffer support, and UserIds can exceed 32-bit range
-- f64 (double) preserves integer precision up to 2^53, which safely covers all current UserIds
-- so this is effectively lossless for now, assuming Roblox doesn't exceed that bound
local bufWriteF64 = buffer.writef64
local bufReadF64 = buffer.readf64

local PlayerType = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function PlayerType.Check(value: any): boolean
	return typeof(value) == "Instance" and (value :: Instance):IsA("Player")
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function PlayerType.Encode(buf: buffer, cursor: number, value: Player, validator: any?): number
	bufWriteF64(buf, cursor, value.UserId)
	return cursor + 8
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function PlayerType.Decode(buf: buffer, cursor: number, validator: any?): (Player?, number)
	local userId: number = bufReadF64(buf, cursor)
	local player: Player? = Players:GetPlayerByUserId(userId)
	return player, cursor + 8
end

return PlayerType
