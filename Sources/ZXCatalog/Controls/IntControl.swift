//
//  ZXCatalog
//  Created by Mauricio Zaquia on 02/01/2025.
//  
  
import SwiftUI

public struct IntControl: CatalogControl {
    public let title: String
    @Binding var number: Int

    public var body: some View {
        VStack(alignment: .leading) {
            Stepper(value: $number, step: 1) {
                Text("\(title): \(number)")
                    .font(.caption)
                    .textCase(.uppercase)
            }
        }
    }

    public init(_ title: String, number: Binding<Int>) {
        self.title = title
        self._number = number
    }
}
