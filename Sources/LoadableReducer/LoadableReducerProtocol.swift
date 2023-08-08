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

/// A protocol declaring a ``Reducer`` that needs to load additional
/// data asynchronously to be ready, starting from an initial state.
public protocol LoadableReducerProtocol: ReducerProtocol where State: LoadedState, State.LoadingState == LoadingState {
    /// The type of the State containing the initial data for loading.
    associatedtype LoadingState: Equatable

    /// The loadable state, which should be used when composing reducers together.
    typealias LoadableState = LoadingReducer<Self>.State
    /// The loadable action, which should be used when composing reducers together.
    typealias LoadableAction = LoadingReducer<Self>.Action

    /// The asynchronous function responsible for loading the data and providing a ready state back into the application.
    ///
    /// - Parameter loadingState: The loading state with metadata for the loading operation.
    /// - Returns: The loaded, or ready, state.
    func load(_ loadingState: LoadingState) async throws -> State

    /// A function determining whether a refresh/reload should take place based on ready actions or not (when `nil` is returned).
    /// - Parameter state: The ready state, which you may use to re-build your `LoadingState`.
    /// - Parameter action: The ready action to evaluate.
    /// - Returns: An update request, or `nil` if no update should happen from the action.
    func updateRequest(for action: Action) -> UpdateRequest?
}

public extension LoadableReducerProtocol {
    func updateRequest(for action: Action) -> UpdateRequest? { nil }
}
