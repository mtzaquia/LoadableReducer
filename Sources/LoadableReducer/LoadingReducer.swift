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

/// A concrete reducer type that can manage the lifecycle events of a ``LoadableReducerProtocol``.
public struct LoadingReducer<LR: LoadableReducerProtocol>: ReducerProtocol {
    public enum State: Equatable {
        case loading(LR.LoadingState)
        case loaded(LR.State)
        case error(_ErrorState)

        public struct _ErrorState: Equatable {
            let loadingState: LR.LoadingState
            let error: Error
            public static func == (lhs: Self, rhs: Self) -> Bool {
                String(reflecting: lhs.error) == String(reflecting: rhs.error)
            }
        }

        internal var asCaseString: String {
            switch self {
            case .loading: return "loading"
            case .loaded: return "loaded"
            case .error: return "error"
            }
        }

        internal var loadingState: LR.LoadingState {
            switch self {
            case .loaded(let loadedState): return loadedState.loadingState
            case .error(let errorState): return errorState.loadingState
            case .loading(let loadingState): return loadingState
            }
        }
    }

    public enum Action {
        case loading(_LoadingAction)
        case loaded(LR.Action)
        case error(_ErrorAction)

        public enum _LoadingAction {
            case load
            case onLoaded(TaskResult<LR.State>)
        }

        public enum _ErrorAction {
            case retry
        }
    }

    private let reducer: LR
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
                state = .error(.init(loadingState: state.loadingState, error: error))
                return .none

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
                let loadingState = state.loadingState
                state = .loading(loadingState)
                return handleLoad(loadingState)
            }
        }
        .ifCaseLet(/State.loaded, action: /Action.loaded) {
            reducer
        }
    }

    /// Creates a concrete reducer to handle the lifecycle of the wrapped ``Reducer``.
    /// - Parameter reducer: The wrapped, loadable reducer.
    public init(reducer: LR) {
        self.reducer = reducer
    }

    private func handleLoad(_ loadingState: LR.LoadingState) -> EffectTask<Action> {
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
