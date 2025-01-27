//
//  NeoUI
//  Created by Mauricio Zaquia on 02/01/2025.
//

import ZXFoundations
import SwiftUI

public struct OneOfControl<S: OneOf>: CatalogControl {
    public let title: String
    @Binding var selection: S
    let ignoredCases: [S.Cases]

    let content: (S.BindingCases) -> [any CatalogControl]

    public var body: some View {
        VStack {
            Picker(title, selection: $selection.choice) {
                ForEach(casesToPick, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }

            let nestedControls = content(S.binding(mutating: $selection))
            if !nestedControls.isEmpty {
                VStack {
                    ForEach(nestedControls, id: \.title) { control in
                        AnyView(control)
                    }
                }
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.tertiary, lineWidth: 1)
                }
            }
        }
    }

    public init(
        title: String,
        selection: Binding<S>,
        ignoring ignoredCases: [S.Cases] = [],
        content: @escaping (
            S.BindingCases
        ) -> [any CatalogControl]
    ) {
        self.title = title
        self._selection = selection
        self.ignoredCases = ignoredCases
        self.content = content
    }

    public init(title: String, selection: Binding<S>, ignoring ignoredCases: [S.Cases] = []) {
        self.title = title
        self._selection = selection
        self.ignoredCases = ignoredCases
        self.content = { _ in [] }
    }

    var casesToPick: [S.Cases] {
        S.allCases.filter { !ignoredCases.contains($0) }
    }
}
