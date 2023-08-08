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

struct MyFeature: LoadableReducerProtocol {
    struct State: LoadedState {
        var loadingState: LoadingState
        var isRefreshing: Bool = false

        @PresentationState var other: OtherFeature.LoadableState?
    }

    enum Action {
        case reload
        case refresh
        case presentOther

        case other(PresentationAction<OtherFeature.LoadableAction>)
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .refresh:
                state.isRefreshing = true
                return .none

            case .presentOther:
                state.other = .loading(.init(name: "MZ"))
                return .none

            case .reload, .other:
                return .none
            }
        }
        .ifLet(\.$other, action: /Action.other) {
            LoadingReducer(reducer: OtherFeature())
        }
    }
}

extension MyFeature {
    struct LoadingState: Equatable {
        let url: URL
    }

    func load(_ loadingState: LoadingState) async throws -> State {
        try await Task.sleep(for: .seconds(2))

//        if Bool.random() {
//            throw URLError(.cancelled)
//        }

        return .init(loadingState: loadingState)
    }

    func updateRequest(for action: Action) -> UpdateRequest? {
        switch action {
        case .reload: return .reload
        case .refresh: return .refresh
        default: return nil
        }
    }
}
