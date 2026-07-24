-- Arbor/src/arbor@1.1.0/Runtime/Children.luau
--!strict
-- arbor-facade-export Runtime.Children
-- arbor-facade-alias ExpectChild = Runtime.Children.ExpectChild
-- arbor-facade-alias FindChild = Runtime.Children.FindChild
-- arbor-facade-alias CollectChildren = Runtime.Children.CollectChildren

local Children = {}

--# Functions

function Children.FindChild(parent: Instance, name: string): Instance?
	return parent:FindFirstChild(name)
end

function Children.ExpectChild(parent: Instance, name: string): Instance
	local child = parent:FindFirstChild(name)

	if not child then
		error(`Missing child "{name}" under {parent:GetFullName()}`)
	end

	return child
end

function Children.CollectChildren(parent: Instance): { [string]: Instance }
	local children = {}
	local seenNames = {}
	local directChildren = parent:GetChildren()

	table.sort(directChildren, function(left: Instance, right: Instance)
		return left.Name < right.Name
	end)

	for _, child in directChildren do
		if seenNames[child.Name] then
			error(`Duplicate child "{child.Name}" under {parent:GetFullName()}`)
		end

		seenNames[child.Name] = true
		children[child.Name] = child
	end

	return children
end

--# Return

return Children
