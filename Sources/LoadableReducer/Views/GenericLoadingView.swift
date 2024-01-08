//
//  
//  Created by Mauricio Zaquia on 08/01/2024.
//  

import ComposableArchitecture
import SwiftUI

public struct GenericLoadingView<State, Action>: View {
    let store: Store<State, Action>

    public var body: some View {
        if #available(macOS 11, *) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            EmptyView()
        }
    }

    public init(store: Store<State, Action>) {
        self.store = store
    }
}
