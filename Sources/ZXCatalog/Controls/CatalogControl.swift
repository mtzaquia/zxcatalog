//
//  ZXCatalog
//  Created by Mauricio Zaquia on 02/01/2025.
//

import SwiftUI

public protocol CatalogControl: View, Identifiable {
    nonisolated var title: String { get }
}

extension CatalogControl {
    public nonisolated var id: String { title }
}
