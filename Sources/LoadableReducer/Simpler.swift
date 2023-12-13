//
//  
//  Created by Mauricio Zaquia on 13/12/2023.
//  
  
import ComposableArchitecture
import SwiftUI

// part 1

public protocol LoadableState {
    var isLoading: Bool { get set }

    associatedtype ReadyState
    var result: Result<ReadyState, LoadError>? { get set }
}

public protocol LoadableAction {
    associatedtype ReadyState
    associatedtype ReadyAction

    static func load(fresh: Bool) -> Self
    static func didLoad(_ result: Result<ReadyState, LoadError>) -> Self

    static func ready(_ ready: ReadyAction) -> Self
}

public typealias Load<I, R> = (I) async throws -> R
public typealias LoadFor<L: Loadable> = (L.State) async throws -> L.Ready.State

public protocol Loadable: Reducer
    where State: LoadableState, Action: LoadableAction,
          State.ReadyState == Ready.State, Action.ReadyState == Ready.State, Action.ReadyAction == Ready.Action {
    associatedtype Ready: Reducer

    var load: LoadFor<Self> { get }
}

public protocol LoadingObserving {
    var isLoading: Bool { get set }
}

// ------------------------------------------------

// part 2

enum LoadDependencyKey: DependencyKey {
    static var liveValue: Any?
}

extension DependencyValues {
    var _$load: Any? {
        get { self[LoadDependencyKey.self] }
        set { self[LoadDependencyKey.self] = newValue }
    }
}

public extension Loadable {
    func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> where Body: Reducer, Body.State == State, Body.Action == Action {
            body
                .dependency(\._$load, load)
                .reduce(into: &state, action: action)
    }
}

public struct LoadingReducer<
    State: LoadableState,
    Action: LoadableAction,
    Ready: Reducer
>: Reducer where
    State.ReadyState == Action.ReadyState,
    State.ReadyState == Ready.State,
    Action.ReadyAction == Ready.Action
{
    @Dependency(\._$load) public var _$load

    @ReducerBuilder<Ready.State, Ready.Action> public var ready: () -> Ready

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            if let shouldLoadFresh = AnyCasePath(Action.load).extract(from: action) {
                state.isLoading = true
                if shouldLoadFresh {
                    state.result = nil
                } else {
                    // TODO: set isLoading if LoadingObserving
                }

                guard let load = _$load as? Load<State, State.ReadyState> else {
                    return .none
                }

                return .run { [state] send in
                    try await send(.didLoad(.success(load(state))))
                } catch: { error, send in
                    await send(.didLoad(.failure(.wrapped(error))))
                }
            } else if let result = AnyCasePath(Action.didLoad).extract(from: action) {
                state.isLoading = false
                state.result = result
                // TODO: set isLoading if LoadingObserving
                return .none
            } else {
                return .none
            }
        }
        .ifLet(\.result, action: /Action.ready) {
            Scope(
                state: AnyCasePath(Result<State.ReadyState, LoadError>.success),
                action: AnyCasePath(
                    embed: { $0 },
                    extract: { $0 }
                ),
                child: ready
            )
        }
    }

    public init(@ReducerBuilder<Ready.State, Ready.Action> ready: @escaping () -> Ready) {
        self.ready = ready
    }
}

// ----------------------------------------------

//public extension Reducer where State: LoadableState, Action: LoadableAction {
//    func ifReady<R: Reducer>(
//        @ReducerBuilder<R.State, R.Action> _ builder: () -> R
//    ) -> _IfLetReducer<Self, Scope<Result<R.State, LoadError>, Action.ReadyAction, R>>
//    where State.ReadyState == R.State, Action.ReadyAction == R.Action {
//        self
//            .ifLet(\.result, action: /Action.ready) {
//                Scope(
//                    state: AnyCasePath(Result<R.State, LoadError>.success),
//                    action: AnyCasePath(
//                        embed: { $0 },
//                        extract: { $0 }
//                    ),
//                    child: builder
//                )
//            }
//    }
//}

// ----------------------------------------------

struct Feature: Reducer, Loadable {
    struct State: LoadableState {
        var isLoading: Bool
        var result: Result<Ready.State, LoadError>?
    }

    enum Action: LoadableAction {
        case load(fresh: Bool)
        case didLoad(Result<Ready.State, LoadError>)

        case ready(Ready.Action)
    }

    var load: LoadFor<Self>
    var body: some ReducerOf<Self> {
        LoadingReducer {
            Ready()
        }
    }
}

extension Feature {
    struct Ready: Reducer {
        struct State {

        }

        enum Action {

        }

        var body: some ReducerOf<Self> {
            EmptyReducer()
        }
    }
}

