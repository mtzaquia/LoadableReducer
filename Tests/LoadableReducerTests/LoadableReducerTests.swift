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

import XCTest
import ComposableArchitecture
@testable import LoadableReducer

//public extension TestStore {
//    convenience init<R: Reducer & Loadable, InitialState: Equatable, ReadyState: Equatable>(
//      initialState: @autoclosure () -> InitialState,
//      @ReducerBuilder<State, Action> reducer: () -> R,
//      withDependencies prepareDependencies: ((inout DependencyValues) -> Void)? = nil
//    ) where State == LoadableState<InitialState, ReadyState>, R.State == State, R.Action == Action {
//        self.init(
//            initialState: LoadableState(initial: initialState()),
//            reducer: reducer,
//            withDependencies: { dependencies in prepareDependencies?(&dependencies) }
//        )
//    }
//}

@MainActor
final class LoadableReducerTests: XCTestCase {
//    struct Client {
//        var load: LoadFor<Sum>
//    }

//    func testSuccess() async throws {
//        let client = Client { .init(sum: $0.var1 + $0.var2) }
//
//        let store = TestStore(
//            initialState: Sum.InitialState(var1: 1, var2: 2)
//        ) {
//            Sum(load: client.load)
//        }
//
//        await store.send(.initial(.load)) {
//            $0.isLoading = true
//        }
//
//        let ready = Sum.ReadyState(sum: 3)
//        await store.receive(.initial(.didLoad(.success(ready)))) {
//            $0.isLoading = false
//            $0.content = .ready(ready)
//        }
//
//        await store.receive(.ready(.happy))
//    }
//
//    func testChildSuccess() async throws {
//        let store = TestStore(
//            initialState: RootFeature.State()
//        ) {
//            RootFeature()
//        }
//
//        await store.send(.present) {
//            $0.sum = .init(initial: .init(var1: 2, var2: 2))
//        }
//
//        await store.send(.sum(.presented(.initial(.load)))) {
//            $0.sum?.isLoading = true
//        }
//
//        let ready = Sum.ReadyState(sum: 4)
//        await store.receive(.sum(.presented(.initial(.didLoad(.success(ready)))))) {
//            $0.sum?.isLoading = false
//            $0.sum?.content = .ready(ready)
//        }
//
//        await store.receive(.sum(.presented(.ready(.happy))))
//    }
//
    func testNestedSuccess() async throws {
        let store = TestStore(
            initialState: Nested.State(carried: 1)
        ) {
            Nested()
        }

        await store.send(.load(fresh: true)) {
            $0.isLoading = true
        }

        let readyOne = Nested.Ready.State(carried: 1)
        await store.receive(.didLoad(.success(readyOne))) {
            $0.isLoading = false
            $0.result = .success(readyOne)
        }

        let nestedTwo = Nested.State(carried: 2)
        await store.send(.ready(.present)) {
            $0.isLoading = false
            $0.result = .success(.init(carried: 1, nested: nestedTwo))
        }

        await store.send(.ready(.nested(.presented(.load(fresh: true))))) {
            var nestedTwo = nestedTwo
            nestedTwo.isLoading = true

            $0.result = .success(.init(carried: 1, nested: nestedTwo))
        }

        let readyTwo = Nested.Ready.State(carried: 2)
        await store.receive(.ready(.nested(.presented(.didLoad(.success(readyTwo)))))) {
            var nestedTwo = nestedTwo
            nestedTwo.isLoading = false
            nestedTwo.result = .success(readyTwo)

            $0.result = .success(.init(carried: 1, nested: nestedTwo))
        }
    }
//
//    func testFailure() async throws {
//        enum TestError: Error {
//            case chris
//        }
//
//        let client = Client { _ in throw TestError.chris }
//
//        let store = TestStore(
//            initialState: Sum.InitialState(var1: 1, var2: 2)
//        ) {
//            Sum(load: client.load)
//        }
//
//        await store.send(.initial(.load)) {
//            $0.isLoading = true
//        }
//
//        let error = LoadError.wrapped(TestError.chris)
//        await store.receive(.initial(.didLoad(.failure(error)))) {
//            $0.isLoading = false
//            $0.content = .error(error)
//        }
//    }
}
