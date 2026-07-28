{{wiki.api.relations.line_1}}
{{wiki.api.relations.line_2}}
{{wiki.api.relations.line_3}}
{{wiki.api.relations.line_4}}

{{wiki.api.relations.line_6}}

{{wiki.api.relations.line_8}}

{{wiki.api.relations.line_10}}

{{wiki.api.relations.line_12}}

{{wiki.api.relations.line_14}}
{{wiki.api.relations.line_15}}
{{wiki.api.relations.line_16}}
{{wiki.api.relations.line_17}}
{{wiki.api.relations.line_18}}
{{wiki.api.relations.line_19}}
{{wiki.api.relations.line_20}}
{{wiki.api.relations.line_21}}

{{wiki.api.relations.line_23}}

{{wiki.api.relations.line_25}}

```lua
Arbor.ChildOf<Child, Parent>
```

{{wiki.api.relations.line_31}}

{{wiki.api.relations.line_33}}
{{wiki.api.relations.line_34}}
{{wiki.api.relations.line_35}}
{{wiki.api.relations.line_36}}

{{wiki.api.relations.line_38}}

{{wiki.api.relations.line_40}}
{{wiki.api.relations.line_41}}
{{wiki.api.relations.line_42}}
{{wiki.api.relations.line_43}}

{{wiki.api.relations.line_45}}

```lua
local fixture = script.Parent.Fixture
local fixtureChild = script.Parent.Fixture.String

type FixtureType = typeof(fixture)
type FixtureStringType = typeof(fixtureChild)

local _validFixtureChild: Arbor.ChildOf<FixtureStringType, FixtureType> = fixtureChild
```

{{wiki.api.relations.line_57}}

{{wiki.api.relations.line_59}}

```lua
Arbor.IsChildOf<Child, Parent>
```

{{wiki.api.relations.line_65}}

{{wiki.api.relations.line_67}}
{{wiki.api.relations.line_68}}
{{wiki.api.relations.line_69}}
{{wiki.api.relations.line_70}}

{{wiki.api.relations.line_72}}

{{wiki.api.relations.line_74}}
{{wiki.api.relations.line_75}}
{{wiki.api.relations.line_76}}
{{wiki.api.relations.line_77}}

{{wiki.api.relations.line_79}}

```lua
type StringIsChild = Arbor.IsChildOf<
    typeof(script.Parent.Fixture.String),
    typeof(script.Parent.Fixture)
>

local _stringIsChild: StringIsChild = true
```

{{wiki.api.relations.line_90}}

{{wiki.api.relations.line_92}}

```lua
Arbor.AncestorOf<Ancestor, Descendant>
```

{{wiki.api.relations.line_98}}

{{wiki.api.relations.line_100}}
{{wiki.api.relations.line_101}}
{{wiki.api.relations.line_102}}
{{wiki.api.relations.line_103}}

{{wiki.api.relations.line_105}}

{{wiki.api.relations.line_107}}
{{wiki.api.relations.line_108}}
{{wiki.api.relations.line_109}}
{{wiki.api.relations.line_110}}

{{wiki.api.relations.line_112}}

{{wiki.api.relations.line_114}}

```lua
Arbor.IsAncestorOf<Ancestor, Descendant>
```

{{wiki.api.relations.line_120}}

{{wiki.api.relations.line_122}}
{{wiki.api.relations.line_123}}
{{wiki.api.relations.line_124}}
{{wiki.api.relations.line_125}}

{{wiki.api.relations.line_127}}

{{wiki.api.relations.line_129}}
{{wiki.api.relations.line_130}}
{{wiki.api.relations.line_131}}
{{wiki.api.relations.line_132}}

{{wiki.api.relations.line_134}}

```lua
type FixtureIsAncestor = Arbor.IsAncestorOf<
    typeof(script.Parent.Fixture),
    typeof(script.Parent.Fixture.String)
>

local _fixtureIsAncestor: FixtureIsAncestor = true
```

{{wiki.api.relations.line_145}}

{{wiki.api.relations.line_147}}

```lua
Arbor.DescendantOf<Descendant, Ancestor>
```

{{wiki.api.relations.line_153}}

{{wiki.api.relations.line_155}}
{{wiki.api.relations.line_156}}
{{wiki.api.relations.line_157}}
{{wiki.api.relations.line_158}}

{{wiki.api.relations.line_160}}

{{wiki.api.relations.line_162}}
{{wiki.api.relations.line_163}}
{{wiki.api.relations.line_164}}
{{wiki.api.relations.line_165}}

{{wiki.api.relations.line_167}}

{{wiki.api.relations.line_169}}

```lua
Arbor.IsDescendantOf<Descendant, Ancestor>
```

{{wiki.api.relations.line_175}}

{{wiki.api.relations.line_177}}
{{wiki.api.relations.line_178}}
{{wiki.api.relations.line_179}}
{{wiki.api.relations.line_180}}

{{wiki.api.relations.line_182}}

{{wiki.api.relations.line_184}}
{{wiki.api.relations.line_185}}
{{wiki.api.relations.line_186}}
{{wiki.api.relations.line_187}}

{{wiki.api.relations.line_189}}

```lua
type StringIsDescendant = Arbor.IsDescendantOf<
    typeof(script.Parent.Fixture.String),
    typeof(script.Parent.Fixture)
>

local _stringIsDescendant: StringIsDescendant = true
```

{{wiki.api.relations.line_200}}

{{wiki.api.relations.line_202}}
{{wiki.api.relations.line_203}}
{{wiki.api.relations.line_204}}
{{wiki.api.relations.line_205}}
{{wiki.api.relations.line_206}}
{{wiki.api.relations.line_207}}

{{wiki.api.relations.line_209}}

{{wiki.api.relations.line_211}}
{{wiki.api.relations.line_212}}
