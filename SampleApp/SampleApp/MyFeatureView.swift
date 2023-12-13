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
import LoadableReducer
import SwiftUI

struct MyFeatureView: View {
    let store: StoreOf<MyFeature>

    var body: some View {
        LoadableStore(store) { readyStore in
            WithViewStore(readyStore, observe: { $0 }) { viewStore in
                VStack {
                    VStack {
                        Text("Ready, count: \(viewStore.count)")

                        Button {
                            viewStore.send(.reload)
                        } label: {
                            Text("Reload").bold()
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            viewStore.send(.refresh)
                        } label: {
                            HStack(spacing: 8) {
                                Text("Refresh").bold()
                                if viewStore.isLoading {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.white)
                                }
                            }
                            .frame(minHeight: 20)
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Divider()

                    Button {
                        viewStore.send(.presentOther)
                    } label: {
                        Text("Present other feature")
                    }
                }
            }
            .sheet(
                store: readyStore.scope(
                    state: \.$other,
                    action: { .other($0) }
                )
            ) { store in
                OtherFeatureView(store: store)
            }
        }
    }
}
