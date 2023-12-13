import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    LoadableMacro.self,
    LoadableStateMacro.self,
    LoadableActionMacro.self
  ]
}
