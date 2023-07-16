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
import Foundation

struct _LoadingReducer<Reducer: LoadableReducerProtocol>: ReducerProtocol {
    typealias State = LoadableState<Reducer>
    typealias Action = _LoadableAction<Reducer>

    private let load: Load<Reducer>
    private let reducer: Reducer

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .initial(.load):
                return handleLoad(state: state)
            case .ready(let readyAction):
                guard case .ready(let readyState) = state,
                      case .reload(let initialState) = reducer.shouldReload(
                        state: readyState,
                        action: readyAction
                      )
                else {
                    return .none
                }

                state = .initial(initialState)
                return handleLoad(state: state)

            case .initial(.onLoaded(.success(let readyState))):
                state = .ready(readyState)
                return .none

            case .initial(.onLoaded(.failure(let error))):
                print(error)
                return .none
            }
        }
        .ifCaseLet(/State.ready, action: /Action.ready) {
            reducer
        }
    }

    init(
        load: @escaping Load<Reducer>,
        reducer: Reducer
    ) {
        self.load = load
        self.reducer = reducer
    }

    private func handleLoad(state: State) -> EffectTask<Action> {
        guard case .initial(let initialState) = state else {
            XCTFail("Loading from a non-initial state. That's not allowed.")
            return .none
        }

        return .run { send in
            let readyState = await load(initialState)
            await send(.initial(.onLoaded(.success(readyState))))
        } catch: { error, send in
            await send(.initial(.onLoaded(.failure(error))))
        }
    }
}
