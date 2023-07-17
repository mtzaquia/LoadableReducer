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
            case .loading(.load):
                guard case .loading(let loadingState) = state else {
                    XCTFail("Loading from a non-initial state. That's not allowed.")
                    return .none
                }

                return handleLoad(loadingState)

            case .loading(.onLoaded(.success(let readyState))):
                state = .loaded(readyState)
                return .none

            case .loading(.onLoaded(.failure(let error))):
                print(error)
                return .none

            case .loaded(let readyAction):
                guard case .loaded(let readyState) = state else {
                    return .none
                }

                switch reducer.updateRequest(for: readyState, action: readyAction) {
                case .refresh(let loadingState):
                    return handleLoad(loadingState)
                case .reload(let loadingState):
                    state = .loading(loadingState)
                    return handleLoad(loadingState)
                case .ignore:
                    return .none
                }
            }
        }
        .ifCaseLet(/State.loaded, action: /Action.loaded) {
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

    private func handleLoad(_ loadingState: Reducer.LoadingState) -> EffectTask<Action> {
        .run { send in
            let loadedState = await load(loadingState)
            await send(.loading(.onLoaded(.success(loadedState))))
        } catch: { error, send in
            await send(.loading(.onLoaded(.failure(error))))
        }
    }
}
