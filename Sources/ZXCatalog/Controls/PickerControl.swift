//
// Created by Mauricio Zaquia
// Copyright ® 2025 Noom, Inc. All Rights Reserved
//

import SFSafeSymbols
import SwiftUI

public struct PickerControl<S: Hashable>: CatalogControl {
    public let title: String
    public let options: [S]
    let displayName: ((S) -> String?)?

    @Binding var selection: S

    @State private var searchTerm: String = ""
    @State private var isPresenting: Bool = false
    let rowBuilder: (S) -> AnyView?

    public var body: some View {
        Button {
            isPresenting = true
        } label: {
            LabeledContent(
                title,
                value: {
                    if let custom = displayName?(selection) {
                        return custom
                    } else {
                        return String(describing: selection)
                    }
                }()
            )
                .contentShape(Rectangle())
        }
        .sheet(isPresented: $isPresenting) {
            NavigationStack {
                List(currentOptions, id: \.self) { option in
                    Button {
                        selection = option
                        isPresenting = false
                    } label: {
                        HStack {
                            if let customView = rowBuilder(option) {
                                customView
                            } else {
                                Text("\(option)")
                                    .foregroundStyle(.primary)
                            }

                            Spacer()

                            if option == selection {
                                Image(systemSymbol: .checkmark)
                            }
                        }
                    }
                }
                .searchable(
                    text: $searchTerm,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search by name"
                )
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            isPresenting = false
                        } label: {
                            Label("Dismiss", systemSymbol: .xmark)
                        }
                    }
                }
            }
        }
    }

    public init<R: View>(
        _ title: String,
        selection: Binding<S>,
        displayName: ((S) -> String?)? = nil,
        options: [S],
        @ViewBuilder rowBuilder: @escaping (S) -> R
    ) {
        self.title = title
        self._selection = selection
        self.displayName = displayName
        self.options = options
        self.rowBuilder = { AnyView(rowBuilder($0)) }
    }

    public init(_ title: String, selection: Binding<S>, displayName: ((S) -> String?)? = nil, options: [S]) {
        self.title = title
        self._selection = selection
        self.displayName = displayName
        self.options = options
        self.rowBuilder = { _ in nil }
    }
}

extension PickerControl {
    var currentOptions: [S] {
        if searchTerm.isEmpty {
            options
        } else {
            options.filter {
                let displayName = displayName?($0) ?? ""
                let description = String(describing: $0)

                return displayName.localizedCaseInsensitiveContains(searchTerm) ||
                    description.localizedCaseInsensitiveContains(searchTerm)
            }
        }
    }
}
