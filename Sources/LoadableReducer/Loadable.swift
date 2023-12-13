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
///// An alias for an asynchronous closure that loads a `Ready.State` from an `InitialState`.
//public typealias LoadFor<L: Loadable> = (L.InitialState) async throws -> L.Ready.State
//
///// Describes a type that can load data from an `InitialState`.
//public protocol Loadable: Reducer where State == LoadableState<Self>, Action == LoadableAction<Ready> {
//    /// The ``InitialState``, or the data available immediately that can be used to load more data.
//    associatedtype InitialState
//    
//    associatedtype Ready: Reducer
//    
//    /// An asynchronous closure that should load a `Ready.State` from a given `InitialState`. It may also
//    /// throw errors.
//    var load: LoadFor<Self> { get }
//}
//
//public extension Loadable where Self: Reducer {
//    typealias State = LoadableState<Self>
//    typealias Action = LoadableAction<Ready>
//
//    func reduce(
//        into state: inout State,
//        action: Action
//    ) -> Effect<Action>
//    where
//        Body: Reducer,
//        Body.State == State,
//        Body.Action == Action
//    {
//        let loadingEffect = _LoadingReducer(load: load)
//            .reduce(into: &state, action: action)
//
//        return .concatenate(
//            loadingEffect,
//            body.reduce(into: &state, action: action)
//        )
//    }
//}
