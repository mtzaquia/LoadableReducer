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
//extension Reducer where Self: Loadable {
//    @inlinable
//    @warn_unqualified_access
//    public func ifReady<Case: Reducer>(
//        @ReducerBuilder<Ready.State, Ready.Action> then case: @escaping () -> Case,
//        fileID: StaticString = #fileID,
//        line: UInt = #line
//    ) -> some ReducerOf<Self> 
//    where
//        Case.State == Ready.State,
//        Case.Action == Ready.Action
//    {
//        _ReadyReducer(base: self, ready: `case`)
//    }
//}
//
//public struct _ReadyReducer<Base: Loadable, Ready: Reducer>: Reducer {
//    public typealias State = Base.State
//    public typealias Action = Base.Action
//
//    let base: Base
//    let ready: () -> Ready
//
//    public var body: some ReducerOf<Self> {
//        base
//        Scope(state: \.content, action: /Action.self) {
//            EmptyReducer()
//                .ifCaseLet(
//                    /Content.ready,
//                    action: /Action.ready,
//                    then: ready
//                )
//        }
//    }
//
//    @usableFromInline
//    init(base: Base, ready: @escaping () -> Ready) {
//        self.base = base
//        self.ready = ready
//    }
//}
