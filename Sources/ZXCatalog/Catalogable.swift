//
//  NeoUI App
//  Created by Mauricio Zaquia on 02/01/2025.
//

import SwiftUI

public protocol Catalogable: View {
    associatedtype Sample: View

    var sample: Sample { get }

    var controls: [any CatalogControl] { get }
}

public extension Catalogable {
    var body: some View {
        CatalogableView(catalogable: self)
    }
}

extension ColorScheme {
    var flipped: ColorScheme {
        switch self {
        case .dark: .light
        case .light: .dark
        @unknown default: fatalError()
        }
    }
}
