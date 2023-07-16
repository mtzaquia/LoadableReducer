# LoadableReducer

An extension to TCA's `ReducerProtocol` to create a reducer that starts with initial data, loads what it needs asynchronously, and shifts to a ready state once done.

## Instalation

`LoadableReducer` is available via Swift Package Manager.

```swift
dependencies: [
  .package(url: "https://github.com/mtzaquia/LoadableReducer.git", branch: "main"),
],
```

## Usage

You can use the `LoadableReducer` in 3 simple steps: reducer, view, and store.

### The reducer

Conform your new reducer with `LoadableReducerProtcol`, and **implement your TCA reducer as you normally would**:
```swift
struct MyFeature: LoadableReducerProtocol { // instead of `ReducerProtocol`
  // ...
}
```

There is one addition needed to complete your conformance. Provide a `LoadingState` type that includes data you will have available when the feature starts, but before it fully loads:
```swift
struct MyFeature: LoadableReducerProtocol {
  struct LoadingState: Equatable { // Your LoadingState must conform to `Equatable`.
    let url: URL
  }

  struct State: Equatable {
    let currentUrl: URL
    // ...
  }

  enum Action {
    case reload // not required, but an example of an action that may reload the feature.
    // ... 
  }

  var body: some ReducerProtocolOf<Self> { /* ... */ }
}
```
> **Note**
> 
> By default, your reducer does the first load when the initial view appears, but you can customise that by providing your own initial view (see [The view](#the-view)).

**[Optional]** You may reload the reducer based on a "ready" action.
```swift
struct MyFeature: LoadableReducerProtocol {
  // ...

  func shouldReload(state: State, action: Action) -> ReloadRequest<LoadingState> {
    if action == .reload {
      return .reload(.init(url: state.currentUrl)) // You will need to provide a new instance of a `LoadingState` here.
    }

    return .ignore // no actions trigger a reload when the reducer is ready by default.
  }
}
```

### The view

Your view implementation must be part of a `LoadableView` type. Simply create your wrapping view, and provide your `body` as you normally would in the `readyView(store:)` function.

```swift
struct MyFeatureView: LoadableView {
  let store: MyFeature.LoadableStore

  func readyView(store: StoreOf<MyFeature>) -> some View { // this is akin to your `body` in a plain `SwiftUI.View`.
    WithViewStore(store) { viewStore in
      Text("Ready, tap to reload.")
        .onTapGesture { viewStore.send(.reload) } // the `reload` action we declared on `MyFeature.Action`.
    }
  }
}
```

**[Optional]** You may override the default initial view. When doing so, make sure to trigger the built-in `load` action at some point, or the loading will never start.

```swift
struct MyFeatureView: LoadableView {
  // ...

  func initialView(store: MyFeature.LoadingStore) -> some View {
    WithViewStore(store) { viewStore in
      Text("Loading...")
        .onAppear { viewStore.send(.load) } // when overriding the default initial view, you must call `load` yourself.
    }
  }
}
```

### The store

A new `convenience init` is added to the TCA's `Store` type. It includes a `load` parameter. This parameter is an asynchronous closure that will
receive the `LoadingState`, may perform `async` operations, and must ultimately return the "ready" State for your reducer.

```swift
MyFeatureView(
  store: .init(
    initialState: .init(url: URL(string: "https://gogle.com")!),
    reducer: MyFeature.init,
    load: { state in
      try? await Task.sleep(for: .seconds(2)) // example of asynchronous work, for now, it must not fail.
      return .init(currentUrl: state.url)
    }
  )
)
```

## Missing features

- [ ] Proper error handling: built-in error view and `retry` action.

## License

Copyright (c) 2023 @mtzaquia

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
