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

import CasePaths
import Foundation

/// An action that encapulates an initial state and a ready state, as well as their actions.
@CasePathable public enum LoadableAction<ReadyAction, ReadyState> {
    /// The actions for whenever a feature is about to load or reload.
    case initial(InitialAction<ReadyState>)
    /// The actions for whenever a feature has already loaded and is ready.
    case ready(ReadyAction)
}

/// The set of actions available when the feature is not ready.
@CasePathable public enum InitialAction<ReadyState> {
    case load
    case reload(discardingContent: Bool)
    case didLoad(Result<ReadyState, LoadError>)
}

extension LoadableAction: Equatable where ReadyAction: Equatable, ReadyState: Equatable {}
extension InitialAction: Equatable where ReadyState: Equatable {}

extension LoadableAction: Hashable where ReadyAction: Hashable, ReadyState: Hashable {}
extension InitialAction: Hashable where ReadyState: Hashable {}
