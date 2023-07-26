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

public struct _LoadingReducer<Reducer: LoadableReducerProtocol>: ReducerProtocol {
    public typealias State = _LoadableState<Reducer>
    public typealias Action = _LoadableAction<Reducer>

    private let reducer: Reducer
    private enum CancelID {
        case load
    }

    public var body: some ReducerProtocolOf<Self> {
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
                switch state {
                case .loading(let loadingState):
                    state = .error(
                        .init(loadingState: loadingState, error: error)
                    )
                    return .none

                case .loaded(let loadedState):
                    state = .error(
                        .init(loadingState: loadedState.loadingState, error: error)
                    )
                    return .none

                case .error(let errorState):
                    state = .error(
                        .init(loadingState: errorState.loadingState, error: error)
                    )
                    return .none
                }

            case .loaded(let readyAction):
                guard case .loaded(let readyState) = state else {
                    return .none
                }

                let loadingState = readyState.loadingState

                switch reducer.updateRequest(for: readyAction) {
                case .reload:
                    state = .loading(loadingState)
                    fallthrough
                case .refresh: return handleLoad(loadingState)
                case .none: return .none
                }

            case .error(.retry):
                let loadingState = {
                    switch state {
                    case .loaded(let loadedState): return loadedState.loadingState
                    case .error(let errorState): return errorState.loadingState
                    case .loading(let loadingState): return loadingState
                    }
                }()

                state = .loading(loadingState)
                return handleLoad(loadingState)
            }
        }
        .ifCaseLet(/State.loaded, action: /Action.loaded) {
            reducer
        }
    }

    init(reducer: Reducer) {
        self.reducer = reducer
    }

    private func handleLoad(_ loadingState: Reducer.LoadingState) -> EffectTask<Action> {
        .concatenate(
            .cancel(id: CancelID.load),
            .run { send in
                let loadedState = try await reducer.load(loadingState)
                await send(.loading(.onLoaded(.success(loadedState))))
            } catch: { error, send in
                await send(.loading(.onLoaded(.failure(error))))
            }
            .cancellable(id: CancelID.load)
        )
    }
}
