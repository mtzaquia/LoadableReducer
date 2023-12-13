import ComposableArchitecture

@attached(memberAttribute)
@attached(extension, conformances: Loadable)
public macro Loadable() =
#externalMacro(
    module: "LoadableReducerMacros", type: "LoadableMacro"
)

@attached(member, names: named(isLoading), named(result))
@attached(extension, conformances: LoadableState)
public macro LoadableState() =
#externalMacro(
    module: "LoadableReducerMacros", type: "LoadableStateMacro"
)

@attached(member, names: named(load), named(didLoad), named(ready))
@attached(extension, conformances: LoadableAction)
public macro LoadableAction() =
#externalMacro(
    module: "LoadableReducerMacros", type: "LoadableActionMacro"
)
