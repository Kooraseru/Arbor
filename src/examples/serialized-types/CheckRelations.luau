-- Arbor/src/examples/serialized-types/CheckRelations.luau
--!strict

--# Modules

-- <arbor-generated-requires>
-- arbor-region-fingerprint: requires 6ce11109
local Arbor = require(game:GetService("ReplicatedStorage").Shared.Packages.Arbor.src["arbor@1.1.0"])
-- </arbor-generated-requires>

--# Types

type StringIsChild = Arbor.IsChildOf<
	typeof(script.Parent.Fixture.String),
	typeof(script.Parent.Fixture)
>

type FixtureIsAncestor = Arbor.IsAncestorOf<
	typeof(script.Parent.Fixture),
	typeof(script.Parent.Fixture.String)
>

type StringIsDescendant = Arbor.IsDescendantOf<
	typeof(script.Parent.Fixture.String),
	typeof(script.Parent.Fixture)
>

type FixtureIsChild = Arbor.IsChildOf<
	typeof(script.Parent.Fixture),
	typeof(script.Parent.Fixture.String)
>

--# Validation

local _stringIsChild: StringIsChild = true
local _fixtureIsAncestor: FixtureIsAncestor = true
local _stringIsDescendant: StringIsDescendant = true
local _fixtureIsChild: FixtureIsChild = false

--# Return

return {}
