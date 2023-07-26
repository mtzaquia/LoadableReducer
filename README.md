# LoadableReducer

An extension to TCA's `ReducerProtocol` to create a reducer that starts with initial data, loads what it needs asynchronously, and shifts to a ready state once done.

## Instalation

`LoadableReducer` is available via Swift Package Manager.

```swift
dependencies: [
  .package(url: "https://github.com/mtzaquia/LoadableReducer.git", .upToNextMajor(from: "0.0.9")),
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

There are two additions needed to complete your conformance. 
- Provide a `LoadingState` type that includes data you will have available when the feature starts, but before it fully loads;
- Conform your `State` type with `LoadedState`. This will require you to hold on to an instance of your `LoadingState`.

```swift
struct MyFeature: LoadableReducerProtocol {
  struct LoadingState: Equatable { // Your LoadingState must conform to `Equatable`.
    var url: URL
  }

  struct State: LoadedState {
    var loadingState: LoadingState 
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
> By default, your reducer does the first load when the initial view appears, but you can customise that by providing your own initial view (see [The view](#the-view)).

**[Optional]** You may refresh or reload the reducer based on a "ready" action. Refreshing will preserve your current loaded content, reloading will not.

```swift
struct MyFeature: LoadableReducerProtocol {
  // ...

  func updateRequest(for action: Action) -> UpdateRequest? {
    if action == .reload {
      return .reload // the `loadingState` from your current `State` will be used, so you
      may update that accordingly in your reducer.
    }

    return nil // no actions trigger a reload when the reducer is ready by default.
  }
}
```

### The view

You can build a view for your loadable reducer with `WithLoadableStore(...)`. An optional `animation` parameter gives you control over the transition animation between states. 

```swift
struct MyFeatureView: View {
  let store: MyFeature.LoadableStore // Declare a store to your loadable reducer using the convenience alias.

  var body: some View {
    WithLoadableStore(store) { loadedStore in
      WithViewStore(loadedStore) { viewStore in
        (Text("Ready. ") + Text("Tap to reload.").bold())
          .onTapGesture { viewStore.send(.reload) }
      }
    }
  }
}
```

**[Optional]** You may override the default loading view. When doing so, make sure to trigger the built-in `load` action at some point, or the loading will never start.

> **Note**
> The same applies for the error view and its `retry` action.

```swift
struct MyFeatureView: View {
  /* ... */

  var body: some View {
    WithLoadableStore(store) { loadedStore in
      /* ... */
    } loading: { loadingStore in
      WithViewStore(loadingStore) { viewStore in
        Text("Hey chris, loading...")
          .onAppear { viewStore.send(.load) } // when overriding the default loading view, you must call `load` yourself.
      }
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
      try await Task.sleep(for: .seconds(2)) // example of asynchronous work. If this fails, the error state will become active.
      return .init(loadingState: state) // pass along your initial state to the ready state for reloading and refreshing when needed.
    }
  )
)
```

## Missing features

- [X] Proper error handling: built-in error view and `retry` action.
- [X] Task cancellation tweaks.

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
