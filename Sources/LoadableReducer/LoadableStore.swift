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

public struct LoadableStore<
    InitialState: Equatable,
    ReadyState: Equatable,
    ReadyAction: Equatable,
    ReadyContent: View,
    InitialContent: View,
    ErrorContent: View
>: View {
    public typealias State = LoadableState<InitialState, ReadyState>
    public typealias Action = LoadableAction<ReadyAction, ReadyState>

    let store: Store<State, Action>
    
    public typealias ReadyContentBuilder = (Store<ReadyState, ReadyAction>) -> ReadyContent
    let readyContent: ReadyContentBuilder

    public typealias InitialContentBuilder = (Store<InitialState, InitialAction<ReadyState>>) -> InitialContent
    let initialContent: InitialContentBuilder

    public typealias ErrorContentBuilder = (Store<LoadError, InitialAction<ReadyState>>) -> ErrorContent
    let errorContent: ErrorContentBuilder

    public var body: some View {
        IfLetStore(
            store.scope(
                state: \.content,
                action: { $0 }
            ),
            then: { contentStore in
                SwitchStore(contentStore) { contentState in
                    switch contentState {
                    case .ready:
                        CaseLet(
                            /Content<ReadyState>.ready,
                            action: Action.ready,
                            then: readyContent
                        )
                    case .error:
                        CaseLet(
                            /Content<ReadyState>.error,
                            action: Action.initial,
                            then: errorContent
                        )
                    }
                }
            },
            else: {
                initialContent(
                    store.scope(
                        state: \.initial,
                        action: Action.initial
                    )
                )
                .onAppear {
                    store.send(.initial(.load))
                }
            }
        )
    }
}

public extension LoadableStore {
    init(
        _ store: Store<State, Action>,
        @ViewBuilder readyContent: @escaping ReadyContentBuilder,
        @ViewBuilder initialContent: @escaping InitialContentBuilder,
        @ViewBuilder errorContent: @escaping ErrorContentBuilder
    ) {
        self.store = store
        self.readyContent = readyContent
        self.initialContent = initialContent
        self.errorContent = errorContent
    }

    init(
        _ store: Store<State, Action>,
        @ViewBuilder readyContent: @escaping ReadyContentBuilder,
        @ViewBuilder initialContent: @escaping InitialContentBuilder
    ) where ErrorContent == DefaultErrorView<ReadyState> {
        self.store = store
        self.readyContent = readyContent
        self.initialContent = initialContent
        self.errorContent = DefaultErrorView.init
    }

    init(
        _ store: Store<State, Action>,
        @ViewBuilder readyContent: @escaping ReadyContentBuilder,
        @ViewBuilder errorContent: @escaping ErrorContentBuilder
    ) where InitialContent == DefaultInitialView {
        self.store = store
        self.readyContent = readyContent
        self.initialContent = DefaultInitialView.init
        self.errorContent = errorContent
    }

    init(
        _ store: Store<State, Action>,
        @ViewBuilder readyContent: @escaping ReadyContentBuilder
    )  where InitialContent == DefaultInitialView, ErrorContent == DefaultErrorView<ReadyState> {
        self.store = store
        self.readyContent = readyContent
        self.initialContent = DefaultInitialView.init
        self.errorContent = DefaultErrorView.init
    }
}

public struct DefaultInitialView: View {
    public var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    init<InitialState, ReadyState>(store: Store<InitialState, InitialAction<ReadyState>>) {}
}

public struct DefaultErrorView<ReadyState: Equatable>: View {
    let store: Store<LoadError, InitialAction<ReadyState>>

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text(viewStore.localizedDescription)
                    .multilineTextAlignment(.center)
                Button {
                    viewStore.send(.reload(discardingContent: true))
                } label: {
                    Text("Retry")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
