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
import LoadableReducer
import SwiftUI

struct Nested: Reducer, Loadable {
    var load: LoadFor<Self> = {
        .init(carried: $0.carried)
    }

    struct State: LoadableState, Equatable {
        var isLoading: Bool = false
        var result: Result<Ready.State, LoadError>? = nil
        var carried: Int
    }

    enum Action: LoadableAction, Equatable {
        case load(fresh: Bool)
        case didLoad(Result<Ready.State, LoadError>)

        case ready(Ready.Action)
    }

    var body: some ReducerOf<Self> {
        LoadingReducer {
            Ready()
        }

//        Reduce { state, action in
//            switch action {
//            case .ready(.present):
//                return .send(.load(fresh: true))
//
//            case .load, .didLoad, .ready:
//                return .none
//            }
//        }
    }

    struct Ready: Reducer {
        struct State: Equatable, LoadingObserving {
            var carried: Int
            @PresentationState var nested: Nested.State?

            var isLoading: Bool = false
        }

        enum Action: Equatable {
            case present

            case nested(PresentationAction<Nested.Action>)
        }

        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .present:
                    state.nested = .init(carried: 2)
                    return .none

                case .nested:
                    return .none
                }
            }
            .ifLet(\.$nested, action: /Action.nested) {
                Nested()
            }
        }
    }
}

struct MyView: View {
    let store: StoreOf<Nested>

    var body: some View {
        LoadableStore(store) { rs in
            EmptyView()
        }
        errorView: { es in
            GenericErrorView(store: es)
        }
        loadingView: {
            EmptyView()
        }
    }
}



//struct Sum: Reducer, Loadable {
//    struct InitialState: Equatable {
//        var var1: Int
//        var var2: Int
//    }
//
//    struct ReadyState: Equatable {
//        var sum: Int
//
//        init(sum: Int) {
//            self.sum = sum
//        }
//    }
//
//    enum ReadyAction: Equatable {
//        case happy
//    }
//
//    var body: some ReducerOf<Self> {
//        Ready {
//            Reduce { state, action in
//                switch action {
//                case .happy:
//                    return .none
//                }
//            }
//        } observing: { state, action in
//            switch action {
//            case .initial(.didLoad(.success)):
//                return .send(.ready(.happy))
//
//            case .initial, .ready:
//                return .none
//            }
//        }
//    }
//
//    var load: LoadFor<Self>
//}
//
//struct RootFeature: Reducer {
//    struct State: Equatable {
//        @PresentationState var sum: Sum.State?
//    }
//
//    enum Action: Equatable {
//        case present
//
//        case sum(PresentationAction<Sum.Action>)
//    }
//
//    var body: some ReducerOf<Self> {
//        Reduce { state, action in
//            switch action {
//            case .present:
//                state.sum = Sum.State(initial: .init(var1: 2, var2: 2))
//                return .none
//
//            case .sum(.presented(.ready(.happy))):
//                // YAY
//                return .none
//
//            case .sum:
//                return .none
//            }
//        }
//        .ifLet(\.$sum, action: /Action.sum) {
//            Sum(load: { .init(sum: $0.var1 + $0.var2) })
//        }
//    }
//}
