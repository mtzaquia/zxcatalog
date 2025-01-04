//
//  ZXCatalog
//  Created by Mauricio Zaquia on 02/01/2025.
//  
  
import SwiftUI

public struct ToggleControl: CatalogControl {
    public let title: String
    @Binding var isOn: Bool

    public var body: some View {
        Toggle(title, isOn: $isOn)
    }

    public init(title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }
}
