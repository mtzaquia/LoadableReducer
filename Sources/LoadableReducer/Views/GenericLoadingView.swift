//
//  
//  Created by Mauricio Zaquia on 08/01/2024.
//  
  
import SwiftUI

public struct GenericLoadingView: View {
    public var body: some View {
        if #available(macOS 11, *) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            EmptyView()
        }
    }

    public init() {}
}
