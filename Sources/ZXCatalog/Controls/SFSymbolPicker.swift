//
//  ZXCatalog
//  Created by Mauricio Zaquia on 28/01/2025.
//  

import SFSafeSymbols
import SwiftUI

public struct SFSymbolPicker: CatalogControl {
    public let title: String
    @Binding var selection: SFSymbol?

    var optional: Bool

    public var body: some View {
        PickerControl(
            title,
            selection: $selection,
            displayName: \.?.rawValue,
            options: (optional ? [nil] : []) + SFSymbol.allSymbols.sorted(by: { $0.rawValue < $1.rawValue }),
            rowBuilder: { sfSymbol in
                if let sfSymbol {
                    Label(sfSymbol.rawValue, systemSymbol: sfSymbol)
                } else {
                    Label(
                        title: {
                            Text("_none_")
                        },
                        icon: {
                            Image("")
                        }
                    )
                }
            }
        )
    }

    public init(title: String, selection: Binding<SFSymbol>) {
        self.title = title
        _selection = .init(
            get: { selection.wrappedValue as SFSymbol? },
            set: { $0.map { selection.wrappedValue = $0 } }
        )
        self.optional = false
    }

    public init(title: String, selection: Binding<SFSymbol?>) {
        self.title = title
        _selection = selection
        self.optional = true
    }
}
