//
//  NeoUI
//  Created by Mauricio Zaquia on 02/01/2025.
//

import SwiftUI

public struct OneOfControl<S: OneOf>: CatalogControl {
    public let title: String
    @Binding var selection: S
    let ignoredCases: [S.Cases]

    let content: (S.BindingCases) -> [any CatalogControl]

    public var body: some View {
        Picker(title, selection: $selection.choice) {
            ForEach(casesToPick, id: \.self) { value in
                Text(S.name(for: value)).tag(value)
            }
        }

        let nestedControls = content(S.binding(mutating: $selection))
        if !nestedControls.isEmpty {
            ForEach(nestedControls, id: \.title) { control in
                AnyView(control)
                    .listRowInsets(EdgeInsets(top: 12, leading: 32, bottom: 12, trailing: 16))
                    .listRowSeparator(.hidden)
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
