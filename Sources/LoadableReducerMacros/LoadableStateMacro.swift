import SwiftDiagnostics
import SwiftOperators
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public enum LoadableStateMacro: ExtensionMacro, MemberMacro {
    public static func expansion<D: DeclGroupSyntax, T: TypeSyntaxProtocol, C: MacroExpansionContext>(
        of node: AttributeSyntax,
        attachedTo declaration: D,
        providingExtensionsOf type: T,
        conformingTo protocols: [TypeSyntax],
        in context: C
    ) throws -> [ExtensionDeclSyntax] {
        if let inheritanceClause = declaration.inheritanceClause,
           inheritanceClause.alreadyInherits(from: Identifiers.loadableStateType)
        {
            return []
        }

        let ext = DeclSyntax("extension \(type.trimmed): \(raw: Identifiers.loadableStateType.qualifiedName) {}")
        return [ext.cast(ExtensionDeclSyntax.self)]
    }

    public static func expansion<D: DeclGroupSyntax, C: MacroExpansionContext>(
        of node: AttributeSyntax,
        providingMembersOf declaration: D,
        in context: C
    ) throws -> [DeclSyntax] {
        [
            DeclSyntax("var isLoading: Bool = false"),
            DeclSyntax("var result: Result<Ready.State, LoadError>? = nil"),
        ]
    }
}
