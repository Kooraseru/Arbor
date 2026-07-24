# Generated Type Facade Example

This example keeps project-owned service types outside Arbor.

`Generated/ServiceTypes.luau` is a user-owned generated facade. It uses Arbor's
generic child operators, but the service tree and facade live beside the
project code they describe.

`ValidateTypes.server.luau` checks the generated aggregate record,
`RequiredChild`, `ChildTypeRecord`, and optional missing-child behavior through
the Luau analyzer.
