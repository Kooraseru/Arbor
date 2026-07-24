-- Arbor/src/arbor@1.1.0/init.luau
--!strict
-- @arbor-entry protocol=1

--# Instructions

--[[
    Rebuild facade after editing Definitions/TypeFunctions:

    Studio:
    ```lua
    local arbor = game.ReplicatedStorage.Shared.Packages.Arbor
    require(arbor.Authoring.FacadeGenerator).Generate(arbor)
    ```

    In this repository, the package root is the versioned ModuleScript under
    `src/`. In exported RBXM artifacts, pass that same ModuleScript root.

    Local CLI:
    ```sh
    python tools/generate-facade.py --src src/arbor@1.1.0
    ```
]]

local Arbor = {}

Arbor.Version = "1.1.0"
Arbor.EntryProtocolVersion = 1

--# Generated, DO NOT TOUCH

-- <arbor-facade-requires>
--# Ancestors
local AncestorOf = require("@self/Definitions/TypeFunctions/Ancestors/Instances/AncestorOf")
local IsAncestorOf = require("@self/Definitions/TypeFunctions/Ancestors/Checks/IsAncestorOf")

--# Children
local Child = require("@self/Definitions/TypeFunctions/Children/Instances/Child")
local ChildNames = require("@self/Definitions/TypeFunctions/Children/Names/ChildNames")
local ChildNamesOfClass = require("@self/Definitions/TypeFunctions/Children/Names/ChildNamesOfClass")
local ChildOf = require("@self/Definitions/TypeFunctions/Children/Instances/ChildOf")
local ChildRecord = require("@self/Definitions/TypeFunctions/Children/Records/ChildRecord")
local ChildTypeRecord = require("@self/Definitions/TypeFunctions/Children/Records/ChildTypeRecord")
local ChildrenOfClass = require("@self/Definitions/TypeFunctions/Children/Records/ChildrenOfClass")
local IsChildOf = require("@self/Definitions/TypeFunctions/Children/Checks/IsChildOf")

--# Descendants
local DescendantOf = require("@self/Definitions/TypeFunctions/Descendants/Instances/DescendantOf")
local IsDescendantOf = require("@self/Definitions/TypeFunctions/Descendants/Checks/IsDescendantOf")

local Mold = require("@self/Mold")
local Run = require("@self/Run")
local FacadeGenerator = require("@self/Authoring/FacadeGenerator")
local RegionPatcher = require("@self/Authoring/RegionPatcher")
local TargetMetadata = require("@self/Authoring/TargetMetadata")
local TypeFacadeGenerator = require("@self/Authoring/TypeFacadeGenerator")
local Children = require("@self/Runtime/Children")
local LoadModuleMap = require("@self/RuntimeLoaders/LoadModuleMap")
-- </arbor-facade-requires>

-- <arbor-facade-public>
Arbor.Authoring = {}
Arbor.Authoring.FacadeGenerator = FacadeGenerator
Arbor.Authoring.RegionPatcher = RegionPatcher
Arbor.Authoring.TargetMetadata = TargetMetadata
Arbor.Authoring.TypeFacadeGenerator = TypeFacadeGenerator
Arbor.Runtime = {}
Arbor.Runtime.Children = Children
Arbor.RuntimeLoaders = {}
Arbor.RuntimeLoaders.LoadModuleMap = LoadModuleMap

Arbor.CollectChildren = Arbor.Runtime.Children.CollectChildren
Arbor.ExpectChild = Arbor.Runtime.Children.ExpectChild
Arbor.FindChild = Arbor.Runtime.Children.FindChild
Arbor.LoadModules = Arbor.RuntimeLoaders.LoadModuleMap.From
-- </arbor-facade-public>

--# Types

-- <arbor-facade-types>
--# Ancestors
export type AncestorOf<Ancestor, Descendant> = Run.Resolve<Mold.Resolve<typeof(AncestorOf), Ancestor, Descendant>>
export type IsAncestorOf<Ancestor, Descendant> = Run.Resolve<Mold.Resolve<typeof(IsAncestorOf), Ancestor, Descendant>>

--# Children
export type Child<Args> = Run.Resolve<Mold.Resolve<typeof(Child), Args, never>>
export type RequiredChild<Parent, Name> = Child<{ Parent: Parent, Name: Name, Mode: "required" }>
export type ChildNames<Parent> = Run.Resolve<Mold.Resolve<typeof(ChildNames), Parent, never>>
export type ChildNamesOfClass<Parent, ClassType> = Run.Resolve<Mold.Resolve<typeof(ChildNamesOfClass), Parent, ClassType>>
export type ChildOf<Child, Parent> = Run.Resolve<Mold.Resolve<typeof(ChildOf), Child, Parent>>
export type ChildRecord<Parent, Value> = Run.Resolve<Mold.Resolve<typeof(ChildRecord), Parent, Value>>
export type ChildTypeRecord<Parent> = Run.Resolve<Mold.Resolve<typeof(ChildTypeRecord), Parent, never>>
export type ChildrenOfClass<Parent, ClassType> = Run.Resolve<Mold.Resolve<typeof(ChildrenOfClass), Parent, ClassType>>
export type IsChildOf<Child, Parent> = Run.Resolve<Mold.Resolve<typeof(IsChildOf), Child, Parent>>

--# Descendants
export type DescendantOf<Descendant, Ancestor> = Run.Resolve<Mold.Resolve<typeof(DescendantOf), Descendant, Ancestor>>
export type IsDescendantOf<Descendant, Ancestor> = Run.Resolve<Mold.Resolve<typeof(IsDescendantOf), Descendant, Ancestor>>

export type Mold<Schema, First, Second> = Mold.Resolve<Schema, First, Second>
export type Run<Molded> = Run.Resolve<Molded>
export type Resolve1<Definition, First> = Run.Resolve<Mold.Resolve<Definition, First, never>>
export type Resolve2<Definition, First, Second> = Run.Resolve<Mold.Resolve<Definition, First, Second>>
-- </arbor-facade-types>

--# Return

return Arbor
