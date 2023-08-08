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
    LR: LoadableReducerProtocol,
    LoadedView: View,
    LoadingView: View,
    ErrorView: View
>: View {
    /// A store to the loadable state from your loadable reducer.
    let store: StoreOf<LoadingReducer<LR>>
    /// An animation to be used for transition between views. Defaults to `nil`.
    let animation: Animation?

    public typealias LoadedBuilder = (
        StoreOf<LR>
    ) -> LoadedView

    public typealias LoadingBuilder = (
        Store<LR.LoadingState, LoadingReducer<LR>.Action._LoadingAction>
    ) -> LoadingView

    public typealias ErrorBuilder = (
        Store<LoadingReducer<LR>.State._ErrorState, LoadingReducer<LR>.Action._ErrorAction>
    ) -> ErrorView

    /// A function providing the ready view. Akin to a regular `body` in a plain `SwiftUI.View`.
    let loadedView: LoadedBuilder
    /// A function providing the initial view. A default implementation is used when `nil`.
    let loadingView: LoadingBuilder?
    /// A function providing the error view. A default implementation is used when `nil`.
    let errorView: ErrorBuilder?

    public var body: some View {
        WithViewStore(store, observe: \.asCaseString) { viewStore in
            SwitchStore(store) { state in
                switch state {
                case .loading:
                    CaseLet(
                        /LoadingReducer<LR>.State.loading,
                         action: LoadingReducer<LR>.Action.loading
                    ) { loadingStore in
                        Group {
                            if let loadingView {
                                loadingView(loadingStore)
                            } else {
                                WithViewStore(loadingStore, observe: { _ in true }) { innerViewStore in
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .onAppear { innerViewStore.send(.load) }
                                }
                            }
                        }
                    }
                case .loaded:
                    CaseLet(
                        /LoadingReducer<LR>.State.loaded,
                         action: LoadingReducer<LR>.Action.loaded,
                         then: loadedView
                    )
                case .error:
                    CaseLet(
                        /LoadingReducer<LR>.State.error,
                         action: LoadingReducer<LR>.Action.error
                    ) { errorStore in
                        Group {
                            if let errorView {
                                errorView(errorStore)
                            } else {
                                WithViewStore(errorStore, observe: { $0 }) { innerViewStore in
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
            }
            .animation(animation, value: viewStore.state)
        }
    }

    /// Creates a new loaded view from a given loadable store, using a default view for loading.
    /// - Parameters:
    ///   - store: A store to the loadable state from your loadable reducer.
    ///   - loaded: The view builder for when the reducer is ready.
    public init(
        _ store: StoreOf<LoadingReducer<LR>>,
        animation: Animation? = nil,
        @ViewBuilder loaded: @escaping LoadedBuilder
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
        _ store: StoreOf<LoadingReducer<LR>>,
        animation: Animation? = nil,
        @ViewBuilder loaded: @escaping LoadedBuilder,
        @ViewBuilder loading: @escaping LoadingBuilder
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
        _ store: StoreOf<LoadingReducer<LR>>,
        animation: Animation? = nil,
        @ViewBuilder loaded: @escaping LoadedBuilder,
        @ViewBuilder error: @escaping ErrorBuilder
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
        _ store: StoreOf<LoadingReducer<LR>>,
        animation: Animation? = nil,
        @ViewBuilder loaded: @escaping LoadedBuilder,
        @ViewBuilder loading: @escaping LoadingBuilder,
        @ViewBuilder error: @escaping ErrorBuilder
    ) {
        self.store = store
        self.animation = animation
        self.loadedView = loaded
        self.loadingView = loading
        self.errorView = error
    }
}
