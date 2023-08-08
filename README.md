# LoadableReducer

An extension to TCA's `Reducer` to create a reducer that starts with initial data, loads what it needs asynchronously, and shifts to a ready state once done.

## Instalation

`LoadableReducer` is available via Swift Package Manager.

```swift
dependencies: [
  .package(url: "https://github.com/mtzaquia/LoadableReducer.git", .upToNextMajor(from: "1.0.0")),
],
```

> **Note:**
> If you haven't migrated to TCA `1.0.0`, you can use version `0.0.9`.

## Usage

You can use the `LoadableReducerProtocol` in 3 simple steps: reducer, view, and store.

### The reducer

Conform your new reducer with `LoadableReducerProtocol`, and implement your TCA reducer as you normally would:

```swift
struct MyFeature: LoadableReducerProtocol { // instead of `ReducerProtocol`
  // ...
}
```

There are three required steps to conform to `LoadableReducerProtocol`:
1. Conform your `State` to `LoadedState`. This will require you to hold on to an instance of your `LoadingState`;
2. Provide a `LoadingState` type that includes data you will have available when the feature starts, but before it fully loads;
3. Declare the `load(_:)` function. It receives the `LoadingState` and returns the reducer's `State`.

```swift
struct MyFeature: LoadableReducerProtocol {
  struct State: LoadedState { // 1. conform your state to `LoadedState`
    var loadingState: LoadingState 
    /* ... */
  }

  enum Action { /* ... */ }
  var body: some ReducerProtocolOf<Self> { /* ... */ }
}

extension MyFeature {
  struct LoadingState: Equatable { // 2. Declare a `LoadingState` type. 
    /* ... */
  }
  
  func load(_ loadingState: LoadingState) async throws -> State { // 3. Add the `load(_:)` function.
    /* ... */
  }
}
```

> **Note:**
> By default, your reducer does the first load when the initial view appears, but you can customise that by providing your own initial view (see [The view](#the-view)).

**[Optional]** You may refresh or reload the reducer based on a "ready" action. Refreshing will preserve your current loaded content, but reloading will not.

```swift
struct MyFeature: LoadableReducerProtocol {
  /* ... */
   
  enum Action {
    case somethingChanged 
    /* ... */ 
  }

  func updateRequest(for action: Action) -> UpdateRequest? {
    if action == .somethingChanged {
      return .reload // the reducer will discard the current data and will fetch new data.
    }

    return nil // does nothing.
  }
}
```

### The view

You can build a view for your loadable reducer with `WithLoadableStore(...)`. An optional `animation` parameter gives you control over the transition animation between states. 

```swift
struct MyFeatureView: View {
  // 1. Declare a store to your loadable reducer using the convenience alias.
  let store: LoadableStoreOf<MyFeature>

  var body: some View {
    // 2. Build your views with the `WithLoadableStore(...)` helper.
    WithLoadableStore(store) { loadedStore in
      WithViewStore(loadedStore) { viewStore in
        VStack {
          Text("Ready!")
          Button("Reload") { viewStore.send(.reload) }
        }
      }
    }
  }
}
```

**[Optional]** You may override the default loading view. When doing so, make sure to trigger the built-in `.load` action at some point, or the loading will never start.

> **Note:**
> The same applies for the error view and its `.retry` action.

```swift
struct MyFeatureView: View {
  /* ... */

  var body: some View {
    WithLoadableStore(store) { loadedStore in
      /* ... */
    } loading: { loadingStore in
      WithViewStore(loadingStore) { viewStore in
        Text("Loading...")
          .onAppear {
            // You must explicitly call `.load` when overriding the default loading view. 
            viewStore.send(.load)
          } 
      }
    }
  }
}
```

### The store

When creating your store, make sure to wrap your `LoadableReducerProtocol` within a `LoadingReducer`.

```swift
MyFeatureView(
  store: .init(
    initialState: .loading(.init(/* ... */))
  ) { 
    LoadingReducer(reducer: MyFeature()) 
  }
)
```

### Composing

When composing features, refer to the `LoadableState` and `LoadableAction` of your `LoadableReducerProtocol`, and don't forget to wrap your composed reducer in a `LoadingReducer`, too.

```swift
struct MyFeature: LoadableReducerProtocol {
  struct State: LoadedState {
    // Refer to the `LoadableState` instead of `State`.
    @PresentationState var other: OtherFeature.LoadableState? 
    
    /* ... */
  }

  enum Action {
    // Refer to the `LoadableAction` instead of `Action`.
    case other(PresentationAction<OtherFeature.LoadableAction>) 
    
    /* ... */
  }

  var body: some ReducerProtocolOf<Self> {
    Reduce { /* ... */ }
      .ifLet(\.$other, action: /Action.other) {
        // Don't forget to wrap your reducer in a `LoadingReducer`!
        LoadingReducer(reducer: OtherFeature()) 
      }
  }
}
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
