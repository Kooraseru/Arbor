-- Arbor/src/examples/serialized-types/IdentifyType.luau
--!strict

--# Modules

-- <arbor-generated-requires>
-- arbor-region-fingerprint: requires 6ce11109
local Arbor = require(game:GetService("ReplicatedStorage").Shared.Packages.Arbor.src["arbor@1.1.0"])
-- </arbor-generated-requires>

--# Types

type ChildNames<Parent> = Arbor.ChildNames<Parent>
type ChildRecord<Parent, Value> = Arbor.ChildRecord<Parent, Value>
type ChildOf<Parent, Value> = Arbor.ChildOf<Parent, Value>

export type TypeModule = {
	Check: (value: unknown) -> boolean,
	Encode: (buf: buffer, cursor: number, value: unknown, validator: unknown?) -> number,
	Decode: (buf: buffer, cursor: number, validator: unknown?) -> (unknown, number),
}

export type TypeId = ChildNames<typeof(script.Parent.Fixture)>
export type TypeModulesRecord = ChildRecord<typeof(script.Parent.Fixture), TypeModule>

--# Analyzer Probes

local fixture = script.Parent.Fixture
local fixtureChild = script.Parent.Fixture.String
local fixtureParent = script.Parent

type FixtureType = typeof(fixture)
type FixtureStringType = typeof(fixtureChild)


local _validFixtureChild: ChildOf<FixtureStringType, FixtureType> = fixtureChild

--# Return

return {
	fixtureParent = fixtureParent,
}
