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
                } else if var ready = try? state.result?.get() as? LoadingObserving {
                    ready.isLoading = true
                    if let ready = ready as? Ready.State {
                        state.result = .success(ready)
                    }
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
                if var ready = try? state.result?.get() as? LoadingObserving {
                    ready.isLoading = false
                    if let ready = ready as? Ready.State {
                        state.result = .success(ready)
                    }
                }
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

public struct GenericLoadingView: View {
    public var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    public init() {}
}

public struct GenericErrorView<Action: LoadableAction>: View {
    let store: Store<LoadError, Action>

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text(viewStore.errorDescription ?? "Unknown error")
                Button("Retry") { viewStore.send(.load(fresh: true)) }
            }
        }
    }

    public init(store: Store<LoadError, Action>) {
        self.store = store
    }
}

public struct LoadableStore<State: LoadableState, Action: LoadableAction, R: View, E: View, L: View>: View {
    let store: Store<State, Action>

    @ViewBuilder let readyView: (Store<State.ReadyState, Action.ReadyAction>) -> R
    @ViewBuilder let errorView: (Store<LoadError, Action>) -> E
    @ViewBuilder let loadingView: () -> L

    public var body: some View {
        IfLetStore(store.scope(state: \.result, action: { $0 })) { store in
            SwitchStore(store) { initialState in
                switch initialState {
                case .success:
                    CaseLet(
                        successState,
                        action: Action.ready,
                        then: readyView
                    )
                case .failure:
                    CaseLet(
                        failureState,
                        action: { $0 },
                        then: errorView
                    )
                }
            }
        } else: {
            loadingView()
                .onAppear { store.send(.load(fresh: true)) }
        }
    }

    public init(
        _ store: Store<State, Action>,
        readyView: @escaping (Store<State.ReadyState, Action.ReadyAction>) -> R
    ) where E == GenericErrorView<Action>, L == GenericLoadingView {
        self.store = store
        self.readyView = readyView
        self.errorView = GenericErrorView.init
        self.loadingView = GenericLoadingView.init
    }

    public init(
        _ store: Store<State, Action>,
        readyView: @escaping (Store<State.ReadyState, Action.ReadyAction>) -> R,
        errorView: @escaping (Store<LoadError, Action>) -> E = GenericErrorView<Action>.init,
        loadingView: @escaping () -> L = GenericLoadingView.init
    ) {
        self.store = store
        self.readyView = readyView
        self.errorView = errorView
        self.loadingView = loadingView
    }

    private func successState(_ state: Result<State.ReadyState, LoadError>) -> State.ReadyState? {
        guard case .success(let success) = state else { return nil }
        return success
    }

    private func failureState(_ state: Result<State.ReadyState, LoadError>) -> LoadError? {
        guard case .failure(let error) = state else { return nil }
        return error
    }
}
