//
//  
//  Created by Mauricio Zaquia on 20/12/2023.
//  

import Foundation
import SwiftSyntax

enum Identifiers {
    static let loadableReducerPackageName = "LoadableReducer"

    static let loadableType = "Loadable"
    static let loadableStateType = "LoadableState"
    static let loadableActionType = "LoadableAction"
}

extension InheritanceClauseSyntax {
    func alreadyInherits(from type: String) -> Bool {
        inheritedTypes.contains(where: {
            [type].withQualified.contains($0.type.trimmedDescription)
        })
    }
}

extension String {
    var qualifiedName: Self {
        "\(Identifiers.loadableReducerPackageName).\(self)"
    }
}

extension Array where Element == String {
    var withQualified: Self {
        flatMap { [$0, $0.qualifiedName] }
    }
}
