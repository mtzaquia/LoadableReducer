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
//public extension Store {
//    /// **[LoadableReducer]** A helper function that allows for the initialisation of a ``Store``
//    /// with an ``InitialState``from a ``Loadable`` feature.
//    /// - Parameters:
//    ///   - initialState: The initial state to start the feature in - it will be used to fully load the feature.
//    ///   - reducer: A reducer conforming to ``Loadable`` that powers the business logic of the application.
//    ///   - prepareDependencies: A closure that can be used to override dependencies that will be accessed
//    ///     by the reducer.
//    convenience init<L: Loadable>(
//        initialState: @autoclosure () -> L.InitialState,
//      @ReducerBuilder<State, Action> reducer: () -> L,
//      withDependencies prepareDependencies: ((inout DependencyValues) -> Void)? = nil
//    ) where L.State == State, L.Action == Action {
//        self.init(
//            initialState: LoadableState(initial: initialState()),
//            reducer: reducer,
//            withDependencies: prepareDependencies
//        )
//    }
//}
