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
public struct WithLoadableStore<
    Reducer: LoadableReducerProtocol,
    LoadedView: View,
    LoadingView: View,
    ErrorView: View
>: View {
    /// A store to the loadable state from your loadable reducer.
    let store: Reducer.LoadableStore
    /// An animation to be used for transition between views. Defaults to `nil`.
    let animation: Animation?

    /// A function providing the ready view. Akin to a regular `body` in a plain `SwiftUI.View`.
    let loadedView: (StoreOf<Reducer>) -> LoadedView
    /// A function providing the initial view. A default implementation is used when `nil`.
    let loadingView: ((Reducer.LoadingStore) -> LoadingView)?
    /// A function providing the error view. A default implementation is used when `nil`.
    let errorView: ((Reducer.ErrorStore) -> ErrorView)?

    public var body: some View {
        WithViewStore(store, observe: \.asCaseString) { viewStore in
            SwitchStore(store) {
                CaseLet(
                    state: /_LoadingReducer<Reducer>.State.loading,
                    action: _LoadingReducer<Reducer>.Action.loading
                ) { loadingStore in
                    Group {
                        if let loadingView {
                            loadingView(loadingStore)
                        } else {
                            WithViewStore(loadingStore) { innerViewStore in
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .onAppear { innerViewStore.send(.load) }
                            }
                        }
                    }
                }
                
                CaseLet(
                    state: /_LoadingReducer<Reducer>.State.loaded,
                    action: _LoadingReducer<Reducer>.Action.loaded,
                    then: loadedView
                )
                
                CaseLet(
                    state: /_LoadingReducer<Reducer>.State.error,
                    action: _LoadingReducer<Reducer>.Action.error
                ) { errorStore in
                    Group {
                        if let errorView {
                            errorView(errorStore)
                        } else {
                            WithViewStore(errorStore) { innerViewStore in
                                VStack {
                                    Text(innerViewStore.error.localizedDescription)
                                        .multilineTextAlignment(.center)
                                    Button {
                                        innerViewStore.send(.retry)
                                    } label: {
                                        Text("Retry")
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                }
            }
            .animation(animation, value: viewStore.state)
        }
    }

    /// Creates a new loaded view from a given loadable store, using a default view for loading.
    /// - Parameters:
    ///   - store: A store to the loadable state from your loadable reducer.
    ///   - loaded: The view builder for when the reducer is ready.
    public init(
        _ store: Reducer.LoadableStore,
        animation: Animation? = nil,
        @ViewBuilder loaded: @escaping (StoreOf<Reducer>) -> LoadedView
    ) where LoadingView == EmptyView, ErrorView == EmptyView {
        self.store = store
        self.animation = animation
        self.loadedView = loaded
        self.loadingView = nil
        self.errorView = nil
    }

    /// Creates a new loaded view and loading view from a given loadable store.
    /// - Parameters:
    ///   - store: A store to the loadable state from your loadable reducer.
    ///   - loaded: The view builder for when the reducer is ready.
    ///   - loading: The view builder for when the reducer is started.
    public init(
        _ store: Reducer.LoadableStore,
        animation: Animation? = nil,
        @ViewBuilder loaded: @escaping (StoreOf<Reducer>) -> LoadedView,
        @ViewBuilder loading: @escaping (Reducer.LoadingStore) -> LoadingView
    ) where ErrorView == EmptyView {
        self.store = store
        self.animation = animation
        self.loadedView = loaded
        self.loadingView = loading
        self.errorView = nil
    }

    /// Creates a new loaded view and error view from a given loadable store.
    /// - Parameters:
    ///   - store: A store to the loadable state from your loadable reducer.
    ///   - loaded: The view builder for when the reducer is ready.
    ///   - error: The view builder for when the reducer fails to load.
    public init(
        _ store: Reducer.LoadableStore,
        animation: Animation? = nil,
        @ViewBuilder loaded: @escaping (StoreOf<Reducer>) -> LoadedView,
        @ViewBuilder error: @escaping (Reducer.ErrorStore) -> ErrorView
    ) where LoadingView == EmptyView {
        self.store = store
        self.animation = animation
        self.loadedView = loaded
        self.loadingView = nil
        self.errorView = error
    }

    /// Creates a new loaded view and loading view from a given loadable store.
    /// - Parameters:
    ///   - store: A store to the loadable state from your loadable reducer.
    ///   - loaded: The view builder for when the reducer is ready.
    ///   - loading: The view builder for when the reducer is started.
    ///   - error: The view builder for when the reducer fails to load.
    public init(
        _ store: Reducer.LoadableStore,
        animation: Animation? = nil,
        @ViewBuilder loaded: @escaping (StoreOf<Reducer>) -> LoadedView,
        @ViewBuilder loading: @escaping (Reducer.LoadingStore) -> LoadingView,
        @ViewBuilder error: @escaping (Reducer.ErrorStore) -> ErrorView
    ) {
        self.store = store
        self.animation = animation
        self.loadedView = loaded
        self.loadingView = loading
        self.errorView = error
    }
}
