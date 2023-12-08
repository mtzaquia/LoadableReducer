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

/// A state that encapulates its initial data and the result of a load, being a ready state or an error.
public struct LoadableState<InitialState, ReadyState> {
    public var initial: InitialState

    var isLoading: Bool = false

    public var content: Content<ReadyState>?

    /// Creates a new ``LoadableState`` with a given ``InitialState``.
    /// - Parameter initial: The initial data, available immediately for use and loading of a ``ReadyState``.
    public init(initial: InitialState) {
        self.initial = initial
    }
}

/// The loaded content of a feature, either the ready state or an error that ocurred during load.
@CasePathable public enum Content<ReadyState> {
    case ready(ReadyState)
    case error(LoadError)
}

extension LoadableState: Equatable where InitialState: Equatable, ReadyState: Equatable {}
extension Content: Equatable where ReadyState: Equatable {}
