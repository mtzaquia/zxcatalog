//
//  ZXCatalog
//  Created by Mauricio Zaquia on 02/01/2025.
//  
  
import SwiftUI

public struct TextControl: CatalogControl {
    public let title: String
    @Binding var text: String

    public var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .textCase(.uppercase)
            TextField(title, text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }

    public init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
}
