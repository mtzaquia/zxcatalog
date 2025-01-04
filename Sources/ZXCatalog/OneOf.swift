//
// Created by Mauricio Tremea Zaquia
// Copyright ® 2025 Mauricio Tremea Zaquia. All rights reserved.
//

import SwiftUI

@attached(
    member,
    names:
        named(BindingCases),
        named(Cases),
        named(binding),
        named(choice)
)
@attached(extension, conformances: OneOf)
public macro OneOf() =
#externalMacro(
    module: "ZXCatalogMacros", type: "OneOfMacro"
)

public protocol OneOf {
    associatedtype Cases: Hashable, CaseIterable
    associatedtype BindingCases

    var choice: Cases { get mutating set }

    static func `default`(for choice: Cases) -> Self
    static func name(for choice: Cases) -> String
    static func binding(mutating choice: Binding<Self>) -> BindingCases
}

public extension OneOf {
    static var allCases: [Cases] { Array(Cases.allCases) }

    static func name(for choice: Cases) -> String { "\(choice)" }
}
