//
//  ZXCatalog
//  Created by Mauricio Zaquia on 13/02/2025.
//  

import SwiftUI

public struct PlaceholderView: View {
    public var body: some View {
        Color(white: 0.85)
            .overlay {
                Rectangle()
                    .strokeBorder(
                        Color(white: 0.7),
                        style: StrokeStyle(
                            lineWidth: 1,
                            dash: [4, 4]
                        )
                    )
            }
    }

    public init() {}
}
