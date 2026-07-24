-- Serialization/TypesRegistry/Model.luau
--!strict

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local bufWriteU32 = buffer.writeu32
local bufReadU32 = buffer.readu32
local bufWriteString = buffer.writestring
local bufReadString = buffer.readstring

local stringFind = string.find
local stringSub = string.sub

local workspacePrefix = "Workspace."

--# Types

type BufferValidator = {
	EnsureSpace: (self: BufferValidator, cursor: number, size: number) -> buffer,
}

local ModelType = {}

--[[
	Checks whether a dynamic value can be encoded by this serializer type.

	@param value Dynamic value to inspect.
	@return Whether this type module accepts the value.
]]
function ModelType.Check(value: unknown): boolean
	return typeof(value) == "Instance" and value:IsA("Model")
end

--[[
	Writes the typed value into the buffer and returns the next cursor position.

	@param buf Buffer receiving encoded bytes.
	@param cursor Current write cursor.
	@param value Value to encode.
	@param validator Registry or encode context used by compound types.
	@return Cursor after the encoded value.
]]
function ModelType.Encode(buf: buffer, cursor: number, value: Model, validator: BufferValidator?): number
	local fullName: string = value:GetFullName()
	local path: string = fullName
	if stringSub(fullName, 1, #workspacePrefix) == workspacePrefix then
		path = stringSub(fullName, #workspacePrefix + 1)
	end

	local length: number = #path
	if validator then
		buf = validator:EnsureSpace(cursor, 4 + length)
	end
	bufWriteU32(buf, cursor, length)
	bufWriteString(buf, cursor + 4, path)
	return cursor + 4 + length
end

--[[
	Finds an instance by a dotted path beneath a known root.

	Model serialization stores paths without the `Workspace.` prefix, so decode resolves from `Workspace` first and then falls back to player character names.

	@param root Instance to resolve from.
	@param path Dotted descendant path.
	@return Matching instance, or nil if any segment is missing.
]]
local function findByPath(root: Instance, path: string): Instance?
	local current: Instance = root
	local start: number = 1
	while true do
		local dotPos: number? = stringFind(path, ".", start, true)
		local segment: string
		if dotPos then
			segment = stringSub(path, start, dotPos - 1)
		else
			segment = stringSub(path, start)
		end
		local child: Instance? = current:FindFirstChild(segment)
		if not child then
			return nil
		end
		if not dotPos then
			return child
		end
		current = child
		start = dotPos + 1
	end
end

--[[
	Reads this type from the buffer and returns the decoded value with the next cursor position.

	@param buf Buffer containing encoded bytes.
	@param cursor Current read cursor.
	@param validator Registry or decode context used by compound types.
	@return Decoded value and cursor after the value.
]]
function ModelType.Decode(buf: buffer, cursor: number, validator: BufferValidator?): (Model?, number)
	local length: number = bufReadU32(buf, cursor)
	local path: string = bufReadString(buf, cursor + 4, length)
	local model: Model? = nil
	if path ~= "" then
		local instance = findByPath(Workspace, path)
		if instance and instance:IsA("Model") then
			model = instance
		end

		if not model then
			for _, player in ipairs(Players:GetPlayers()) do
				if player.Name == path and player.Character then
					model = player.Character
					break
				end
			end
		end
	end
	return model, cursor + 4 + length
end

return ModelType
