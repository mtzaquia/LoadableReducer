//
//  Copyright (c) 2023 @mtzaquia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import ComposableArchitecture
import SwiftUI

/// A helper view to deal with loadable stores from ``LoadableReducerProtocol`` types.
public struct WithLoadableStore<Reducer: LoadableReducerProtocol, Loaded: View, Loading: View>: View {
    /// A store to the loadable state from your loadable reducer.
    let store: Reducer.LoadableStore

    /// A function providing the ready view. Akin to a regular `body` in a plain `SwiftUI.View`.
    let loaded: (StoreOf<Reducer>) -> Loaded
    /// A function providing the initial view. A default implementation is used when `nil`.
    let loading: ((Reducer.LoadingStore) -> Loading)?

    public var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /_LoadingReducer<Reducer>.State.loading,
                action: _LoadingReducer<Reducer>.Action.loading
            ) { loadingStore in
                Group {
                    if let loading {
                        loading(loadingStore)
                    } else {
                        WithViewStore(loadingStore) { viewStore in
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onAppear { viewStore.send(.load) }
                        }
                    }
                }
            }

            CaseLet(
                state: /_LoadingReducer<Reducer>.State.loaded,
                action: _LoadingReducer<Reducer>.Action.loaded,
                then: loaded
            )
        }
    }

    /// Creates a new loaded view from a given loadable store, using a default view for loading.
    /// - Parameters:
    ///   - store: A store to the loadable state from your loadable reducer.
    ///   - loaded: The view builder for when the reducer is ready.
    public init(
        _ store: Reducer.LoadableStore,
        @ViewBuilder loaded: @escaping (StoreOf<Reducer>) -> Loaded
    ) where Loading == EmptyView {
        self.store = store
        self.loaded = loaded
        self.loading = nil
    }

    /// Creates a new loaded view and loading view from a given loadable store.
    /// - Parameters:
    ///   - store: A store to the loadable state from your loadable reducer.
    ///   - loaded: The view builder for when the reducer is ready.
    ///   - loading: The view builder for when the reducer is started.
    public init(
        _ store: Reducer.LoadableStore,
        @ViewBuilder loaded: @escaping (StoreOf<Reducer>) -> Loaded,
        @ViewBuilder loading: @escaping (Reducer.LoadingStore) -> Loading
    ) {
        self.store = store
        self.loaded = loaded
        self.loading = loading
    }
}
