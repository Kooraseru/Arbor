-- Arbor/src/init.luau
--!strict

--# Modules

local ChildNames = require("@self/InstanceTree/ChildNames")
local ChildNamesOfClass = require("@self/InstanceTree/ChildNamesOfClass")
local ChildRecord = require("@self/InstanceTree/ChildRecord")
local ChildOf = require("@self/InstanceTree/ChildOf")
local ChildrenOfClass = require("@self/InstanceTree/ChildrenOfClass")
local LoadModuleMap = require("@self/RuntimeLoaders/LoadModuleMap")

--# Types

export type ChildNames<T> = ChildNames.Of<T>
export type ChildNamesOfClass<T, ClassName> = ChildNamesOfClass.Of<T, ClassName>
export type ChildRecord<T, V> = ChildRecord.Of<T, V>
export type ChildOf<T, Name> = ChildOf.Of<T, Name>
export type ChildrenOfClass<T, ClassName> = ChildrenOfClass.Of<T, ClassName>
export type ModuleValidator<T> = LoadModuleMap.ModuleValidator<T>

--# Facade

return {
	InstanceTree = {
		ChildNames = ChildNames,
		ChildNamesOfClass = ChildNamesOfClass,
		ChildRecord = ChildRecord,
		ChildOf = ChildOf,
		ChildrenOfClass = ChildrenOfClass,
	},
	RuntimeLoaders = {
		LoadModuleMap = LoadModuleMap,
	},
}
