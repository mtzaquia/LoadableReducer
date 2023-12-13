////
////  Copyright (c) 2023 @mtzaquia
////
////  Permission is hereby granted, free of charge, to any person obtaining a copy
////  of this software and associated documentation files (the "Software"), to deal
////  in the Software without restriction, including without limitation the rights
////  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
////  copies of the Software, and to permit persons to whom the Software is
////  furnished to do so, subject to the following conditions:
////
////  The above copyright notice and this permission notice shall be included in all
////  copies or substantial portions of the Software.
////
////  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
////  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
////  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
////  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
////  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
////  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
////  SOFTWARE.
////
//
//import ComposableArchitecture
//
//struct _LoadingReducer<L: Loadable>: Reducer {
//    typealias State = LoadableState<L>
//    typealias Action = LoadableAction<L.Ready>
//
//    var load: LoadFor<L>
//
//    var body: some ReducerOf<Self> {
//        Reduce { state, action in
//            switch action {
//            case .initial(.load):
//                state.isLoading = true
//                return .run { [initial = state.initial] send in
//                    try await send(.initial(.didLoad(.success(load(initial)))))
//                } catch: { error, send in
//                    await send(.initial(.didLoad(.failure(.wrapped(error)))))
//                }
//
//            case .initial(.reload(let discardingContent)):
//                state.isLoading = true
//                if discardingContent {
//                    state.content = nil
//                }
//
//                return .run { [initial = state.initial] send in
//                    try await send(.initial(.didLoad(.success(load(initial)))))
//                } catch: { error, send in
//                    await send(.initial(.didLoad(.failure(.wrapped(error)))))
//                }
//
//            case .initial(.didLoad(.success(let loadedState))):
//                state.isLoading = false
//                state.content = .ready(loadedState)
//                return .none
//
//            case .initial(.didLoad(.failure(let error))):
//                state.isLoading = false
//                state.content = .error(error)
//                return .none
//
//            case .ready:
//                return .none
//            }
//        }
//    }
//}
