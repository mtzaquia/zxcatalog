//
// Created by Mauricio Tremea Zaquia
// Copyright ® 2025 Mauricio Tremea Zaquia. All rights reserved.
//

import SwiftUI

/// A macro that annotates an enumeration as an union type.
@attached(member, names: named(BindingCases), named(Cases), named(binding), named(`default`(for:)), named(choice))
@attached(extension, conformances: OneOf)
public macro OneOf() = #externalMacro(module: "ZXCatalogMacros", type: "OneOfMacro")

/// A protocol defining an enumeration that acts as an union type.
public protocol OneOf {
    /// The plain cases of the enumeration.
    associatedtype Cases: Hashable, CaseIterable
    /// The cases from the enumeration, using derived bindings to the associated values as parameters.
    associatedtype BindingCases

    /// The currently selected case.
    var choice: Cases { get mutating set }

    /// Returns the case with the default associated values to be used for a given choice.
    ///
    /// - Parameter choice: The currently selected choise.
    static func `default`(for choice: Cases) -> Self

    /// Return all possible cases of this type.
    static var allCases: [Cases] { get }

    /// Returns a UI-friendly name for a given choice.
    /// - Parameter choice: The currently selected choise.
    static func name(for choice: Cases) -> String

    /// Returns a ``BindingCases`` version for the currently selected choice.
    static func binding(mutating choice: Binding<Self>) -> BindingCases
}

public extension OneOf {
    static var allCases: [Cases] { Array(Cases.allCases) }

    static func name(for choice: Cases) -> String { "\(choice)" }
}
