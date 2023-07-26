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

public extension ReducerProtocol {
    /// Embeds a child reducer in a parent domain that works on an optional property of parent state.
    ///
    /// This version of `ifLet` requires the usage of ``PresentationState`` and ``PresentationAction``
    /// in your feature's domain.
    ///
    /// - Parameters:
    ///   - toPresentationState: A writable key path from parent state to a property containing child
    ///     presentation state.
    ///   - toPresentationAction: A case path from parent action to a case containing child actions.
    ///   - destination: A reducer that will be invoked with child actions against presented child
    ///     state.
    /// - Returns: A reducer that combines the child reducer with the parent reducer.
    @warn_unqualified_access
    func ifLet<Destination: LoadableReducerProtocol>(
        _ toPresentationState: WritableKeyPath<State, PresentationState<Destination.LoadableState>>,
        action toPresentationAction: CasePath<Action, PresentationAction<Destination.LoadableAction>>,
      @ReducerBuilder<Destination.State, Destination.Action> destination: () -> Destination,
      fileID: StaticString = #fileID,
      line: UInt = #line
    ) -> _PresentationReducer<Self, _LoadingReducer<Destination>> {
        self.ifLet(
            toPresentationState,
            action: toPresentationAction,
            destination: { _LoadingReducer(reducer: destination()) },
            fileID: fileID,
            line: line
        )
    }

    /// Embeds a child reducer in a parent domain that works on an optional property of parent state.
    ///
    /// - Parameters:
    ///   - toWrappedState: A writable key path from parent state to a property containing optional
    ///     child state.
    ///   - toWrappedAction: A case path from parent action to a case containing child actions.
    ///   - wrapped: A reducer that will be invoked with child actions against non-optional child
    ///     state.
    /// - Returns: A reducer that combines the child reducer with the parent reducer.
    @warn_unqualified_access
    func ifLet<Wrapped: LoadableReducerProtocol>(
        _ toWrappedState: WritableKeyPath<State, Wrapped.LoadableState?>,
        action toWrappedAction: CasePath<Action, Wrapped.LoadableAction>,
      @ReducerBuilder<Wrapped.State, Wrapped.Action> then wrapped: () -> Wrapped,
      fileID: StaticString = #fileID,
      line: UInt = #line
    ) -> _IfLetReducer<Self, _LoadingReducer<Wrapped>> {
        self.ifLet(
            toWrappedState,
            action: toWrappedAction,
            then: { _LoadingReducer(reducer: wrapped()) },
            fileID: fileID,
            line: line
        )
    }
}
