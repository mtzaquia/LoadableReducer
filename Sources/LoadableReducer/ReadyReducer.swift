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

public struct Ready<
    R: Reducer,
    InitialState: Equatable,
    ReadyState: Equatable,
    ReadyAction: Equatable
>: Reducer where
    R.State == ReadyState,
    R.Action == ReadyAction
{
    public typealias State = LoadableState<InitialState, ReadyState>
    public typealias Action = LoadableAction<ReadyAction, ReadyState>

    let ready: () -> R

    public typealias ReduceObserving = (inout State, Action) -> Effect<Action>
    let observing: ReduceObserving

    public var body: some ReducerOf<Self> {
        Scope(state: \.content, action: /Action.self) {
            EmptyReducer()
                .ifCaseLet(/Content.ready, action: /Action.ready) {
                    ready()
                }
        }

        Reduce(observing)
    }

    public init(_ ready: @escaping () -> R, observing: @escaping ReduceObserving = { _, _ in .none }) {
        self.ready = ready
        self.observing = observing
    }
}
