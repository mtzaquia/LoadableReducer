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

/// A protocol describing a view that works alongside a ``LoadableReducerProtocol``.
public protocol LoadableView: View {
    /// The reducer for the `ready` state of this view.
    associatedtype Reducer: LoadableReducerProtocol
    /// The initial view, or loading view, type.
    associatedtype Initial: View
    /// The ready view, or loaded view, type.
    associatedtype Ready: View

    /// A store to the loadable state, or top-level state, of the ready reducer.
    var store: Reducer.LoadableStore { get }

    /// A function providing the initial view. This protocol provides a default implementation
    /// for this view, but you may override it as needed.
    /// - Parameter store: The loading store.
    func initialView(store: Reducer.LoadingStore) -> Initial

    /// A function providing the ready view. Akin to a regular `body` in a plain `SwiftUI.View`.
    /// - Parameter store: The reducer's store.
    func readyView(store: StoreOf<Reducer>) -> Ready
}

public extension LoadableView {
    var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /_LoadingReducer<Reducer>.State.initial,
                action: _LoadingReducer<Reducer>.Action.initial,
                then: initialView
            )

            CaseLet(
                state: /_LoadingReducer<Reducer>.State.ready,
                action: _LoadingReducer<Reducer>.Action.ready,
                then: readyView
            )
        }
    }

    func initialView(store: Reducer.LoadingStore) -> some View {
        WithViewStore(store) { viewStore in
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                .onAppear { viewStore.send(.load) }
        }
    }
}
