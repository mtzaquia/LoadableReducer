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

public struct LoadingReducer<
    State: LoadableState,
    Action: LoadableAction,
    Ready: Reducer
>: Reducer where
    State.ReadyState == Action.ReadyState,
    State.ReadyState == Ready.State,
    Action.ReadyAction == Ready.Action
{
    @Dependency(\._$load) public var _$load

    @ReducerBuilder<Ready.State, Ready.Action> public var ready: () -> Ready

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            if let shouldLoadFresh = AnyCasePath(Action.load).extract(from: action) {
                state.isLoading = true
                if shouldLoadFresh {
                    state.result = nil
                } else if var ready = try? state.result?.get() as? LoadingObserving {
                    ready.isLoading = true
                    if let ready = ready as? Ready.State {
                        state.result = .success(ready)
                    }
                }

                guard let load = _$load as? Load<State, State.ReadyState> else {
                    return .none
                }

                return .run { [state] send in
                    try await send(.didLoad(.success(load(state))))
                } catch: { error, send in
                    await send(.didLoad(.failure(.wrapped(error))))
                }
            } else if let result = AnyCasePath(Action.didLoad).extract(from: action) {
                state.isLoading = false
                state.result = result
                if var ready = try? state.result?.get() as? LoadingObserving {
                    ready.isLoading = false
                    if let ready = ready as? Ready.State {
                        state.result = .success(ready)
                    }
                }
                return .none
            } else {
                return .none
            }
        }
        .ifLet(\.result, action: /Action.ready) {
            Scope(
                state: AnyCasePath(Result<State.ReadyState, LoadError>.success),
                action: AnyCasePath(
                    embed: { $0 },
                    extract: { $0 }
                ),
                child: ready
            )
        }
    }

    public init(@ReducerBuilder<Ready.State, Ready.Action> ready: @escaping () -> Ready) {
        self.ready = ready
    }
}
