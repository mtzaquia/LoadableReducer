//
//  
//  Created by Mauricio Zaquia on 08/01/2024.
//  
 
import ComposableArchitecture
import SwiftUI

public struct GenericErrorView<Action: LoadableAction>: View {
    let store: Store<LoadError, Action>

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text(viewStore.errorDescription ?? "Unknown error")
                Button("Retry") { viewStore.send(.load(fresh: true)) }
            }
        }
    }

    public init(store: Store<LoadError, Action>) {
        self.store = store
    }
}
