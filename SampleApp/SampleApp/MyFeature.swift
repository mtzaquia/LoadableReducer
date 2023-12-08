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

struct MyFeature: Reducer, Loadable {
    struct InitialState: Equatable {
        var url: URL
        var count = 1
    }

    struct ReadyState: Equatable {
        var isRefreshing = false
        var count: Int
        @PresentationState var other: OtherFeature.State?
    }

    enum ReadyAction: Equatable {
        case presentOther

        case reload
        case refresh

        case other(PresentationAction<OtherFeature.Action>)
    }

    var body: some ReducerOf<Self> {
        Ready {
            Reduce { state, action in
                switch action {
                case .presentOther:
                    state.other = .init(initial: .init(name: "MZ"))
                    return .none

                case .reload, .refresh, .other:
                    return .none
                }
            }
            .ifLet(\.$other, action: /ReadyAction.other) {
                OtherFeature()
            }
        } observing: { state, action in
            switch action {
            case .ready(.reload): 
                state.initial.count = 1
                return .send(.initial(.reload(discardingContent: true)))

            case .ready(.refresh):
                state.content?.modify(\.ready) {
                    $0.isRefreshing = true
                }
                state.initial.count += 1
                return .send(.initial(.reload(discardingContent: false)))

            default: return .none
            }
        }
    }

    var load: LoadFor<MyFeature> = { initialState in
        try await Task.sleep(for: .seconds(2))

//        if Bool.random() {
//            throw URLError(.cancelled)
//        }

        return MyFeature.ReadyState(count: initialState.count)
    }
}
