{{wiki.api.children.line_1}}
{{wiki.api.children.line_2}}
{{wiki.api.children.line_3}}
{{wiki.api.children.line_4}}

{{wiki.api.children.line_6}}

{{wiki.api.children.line_8}}

{{wiki.api.children.line_10}}

{{wiki.api.children.line_12}}

{{wiki.api.children.line_14}}
{{wiki.api.children.line_15}}
{{wiki.api.children.line_16}}
{{wiki.api.children.line_17}}
{{wiki.api.children.line_18}}
{{wiki.api.children.line_19}}
{{wiki.api.children.line_20}}
{{wiki.api.children.line_21}}
{{wiki.api.children.line_22}}

{{wiki.api.children.line_24}}

{{wiki.api.children.line_26}}

```lua
Arbor.Child<{ Parent: Parent, Name: Name, Mode: "checked" | "optional" | "required"? }>
```

{{wiki.api.children.line_32}}

{{wiki.api.children.line_34}}

{{wiki.api.children.line_36}}
{{wiki.api.children.line_37}}
{{wiki.api.children.line_38}}
{{wiki.api.children.line_39}}
{{wiki.api.children.line_40}}

{{wiki.api.children.line_42}}

{{wiki.api.children.line_44}}
{{wiki.api.children.line_45}}
{{wiki.api.children.line_46}}
{{wiki.api.children.line_47}}
{{wiki.api.children.line_48}}

{{wiki.api.children.line_50}}

{{wiki.api.children.line_52}}
{{wiki.api.children.line_53}}
{{wiki.api.children.line_54}}

{{wiki.api.children.line_56}}

```lua
export type StringModule = Arbor.Child<{
    Parent: typeof(script.Parent.Fixture),
    Name: "String",
    Mode: "required",
}>
```

{{wiki.api.children.line_66}}

{{wiki.api.children.line_68}}

```lua
Arbor.RequiredChild<Parent, Name>
```

{{wiki.api.children.line_74}}

{{wiki.api.children.line_76}}

{{wiki.api.children.line_78}}
{{wiki.api.children.line_79}}
{{wiki.api.children.line_80}}
{{wiki.api.children.line_81}}

{{wiki.api.children.line_83}}

{{wiki.api.children.line_85}}
{{wiki.api.children.line_86}}
{{wiki.api.children.line_87}}
{{wiki.api.children.line_88}}

{{wiki.api.children.line_90}}

```lua
export type dataservice = Arbor.RequiredChild<
    typeof(script.Parent.ServerServices),
    "DataService"
>
```

{{wiki.api.children.line_99}}

{{wiki.api.children.line_101}}

```lua
Arbor.ChildNames<Parent>
```

{{wiki.api.children.line_107}}

{{wiki.api.children.line_109}}

{{wiki.api.children.line_111}}
{{wiki.api.children.line_112}}
{{wiki.api.children.line_113}}
{{wiki.api.children.line_114}}

{{wiki.api.children.line_116}}

```lua
export type TypeId = Arbor.ChildNames<typeof(script.Parent.Fixture)>
```

{{wiki.api.children.line_122}}

{{wiki.api.children.line_124}}

```lua
Arbor.ChildNamesOfClass<Parent, ClassType>
```

{{wiki.api.children.line_130}}

{{wiki.api.children.line_132}}

{{wiki.api.children.line_134}}
{{wiki.api.children.line_135}}
{{wiki.api.children.line_136}}
{{wiki.api.children.line_137}}

{{wiki.api.children.line_139}}

{{wiki.api.children.line_141}}
{{wiki.api.children.line_142}}
{{wiki.api.children.line_143}}
{{wiki.api.children.line_144}}

{{wiki.api.children.line_146}}

{{wiki.api.children.line_148}}

```lua
Arbor.ChildRecord<Parent, Value>
```

{{wiki.api.children.line_154}}

{{wiki.api.children.line_156}}

{{wiki.api.children.line_158}}
{{wiki.api.children.line_159}}
{{wiki.api.children.line_160}}
{{wiki.api.children.line_161}}

{{wiki.api.children.line_163}}

{{wiki.api.children.line_165}}
{{wiki.api.children.line_166}}
{{wiki.api.children.line_167}}

{{wiki.api.children.line_169}}

```lua
export type TypeModulesRecord = Arbor.ChildRecord<
    typeof(script.Parent.Fixture),
    TypeModule
>
```

{{wiki.api.children.line_178}}

{{wiki.api.children.line_180}}

```lua
Arbor.ChildTypeRecord<Parent>
```

{{wiki.api.children.line_186}}

{{wiki.api.children.line_188}}

{{wiki.api.children.line_190}}
{{wiki.api.children.line_191}}
{{wiki.api.children.line_192}}

{{wiki.api.children.line_194}}

{{wiki.api.children.line_196}}
{{wiki.api.children.line_197}}
{{wiki.api.children.line_198}}

{{wiki.api.children.line_200}}

{{wiki.api.children.line_202}}

```lua
Arbor.ChildrenOfClass<Parent, ClassType>
```

{{wiki.api.children.line_208}}

{{wiki.api.children.line_210}}

{{wiki.api.children.line_212}}
{{wiki.api.children.line_213}}
{{wiki.api.children.line_214}}
{{wiki.api.children.line_215}}

{{wiki.api.children.line_217}}

{{wiki.api.children.line_219}}
{{wiki.api.children.line_220}}
{{wiki.api.children.line_221}}
{{wiki.api.children.line_222}}

{{wiki.api.children.line_224}}

{{wiki.api.children.line_226}}
{{wiki.api.children.line_227}}
{{wiki.api.children.line_228}}
{{wiki.api.children.line_229}}
{{wiki.api.children.line_230}}
{{wiki.api.children.line_231}}

{{wiki.api.children.line_233}}

{{wiki.api.children.line_235}}
{{wiki.api.children.line_236}}
{{wiki.api.children.line_237}}
