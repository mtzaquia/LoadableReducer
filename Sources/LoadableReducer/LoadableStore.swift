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

public struct LoadableStore<State: LoadableState, Action: LoadableAction, R: View, E: View, L: View>: View {
    let store: Store<State, Action>

    @ViewBuilder let readyView: (Store<State.ReadyState, Action.ReadyAction>) -> R
    @ViewBuilder let errorView: (Store<LoadError, Action>) -> E
    @ViewBuilder let loadingView: () -> L

    public var body: some View {
        IfLetStore(store.scope(state: \.result, action: { $0 })) { store in
            SwitchStore(store) { initialState in
                switch initialState {
                case .success:
                    CaseLet(
                        successState,
                        action: Action.ready,
                        then: readyView
                    )
                case .failure:
                    CaseLet(
                        failureState,
                        action: { $0 },
                        then: errorView
                    )
                }
            }
        } else: {
            loadingView()
                .onAppear { store.send(.load(fresh: true)) }
        }
    }

    public init(
        _ store: Store<State, Action>,
        readyView: @escaping (Store<State.ReadyState, Action.ReadyAction>) -> R
    ) where E == GenericErrorView<Action>, L == GenericLoadingView {
        self.store = store
        self.readyView = readyView
        self.errorView = GenericErrorView.init
        self.loadingView = GenericLoadingView.init
    }

    public init(
        _ store: Store<State, Action>,
        readyView: @escaping (Store<State.ReadyState, Action.ReadyAction>) -> R,
        errorView: @escaping (Store<LoadError, Action>) -> E = GenericErrorView<Action>.init,
        loadingView: @escaping () -> L = GenericLoadingView.init
    ) {
        self.store = store
        self.readyView = readyView
        self.errorView = errorView
        self.loadingView = loadingView
    }

    private func successState(_ state: Result<State.ReadyState, LoadError>) -> State.ReadyState? {
        guard case .success(let success) = state else { return nil }
        return success
    }

    private func failureState(_ state: Result<State.ReadyState, LoadError>) -> LoadError? {
        guard case .failure(let error) = state else { return nil }
        return error
    }
}
