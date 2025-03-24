//
// Created by Mauricio Zaquia
// Copyright ® 2025 Noom, Inc. All Rights Reserved
//

import ConcurrencyExtras
import SwiftUI

extension Binding {
    func onNone<Wrapped>(_ fallback: @Sendable @escaping () -> Wrapped) -> Binding<Wrapped> where Value == Optional<Wrapped> {
        let uncheckedSelf = UncheckedSendable(self)
        return Binding<Wrapped>(
            get: { uncheckedSelf.value.wrappedValue ?? fallback() },
            set: { value in uncheckedSelf.value.wrappedValue = value }
        )
    }
}

extension Optional: CaseIterable where Wrapped: CaseIterable {
    public static var allCases: [Wrapped?] { Wrapped.allCases.map { $0 as Wrapped? } + [.none] }
}

extension Optional: OneOf where Wrapped: OneOf {
    public var choice: Wrapped.Cases? {
        get {
            switch self {
            case .some(let value): value.choice
            case .none: .none
            }
        }
        set {
            self = Self.default(for: newValue)
        }
    }

    public static func `default`(for choice: Wrapped.Cases?) -> Wrapped? {
        switch choice {
        case .some(let value): Wrapped.default(for: value)
        case .none: .none
        }
    }

    public static func binding(mutating choice: Binding<Wrapped?>) -> Wrapped.BindingCases? {
        switch choice.wrappedValue {
        case .some(let value):
            return Wrapped.binding(mutating: choice.onNone({ value }))
        case .none:
            return .none
        }
    }

    public static func name(for choice: Wrapped.Cases?) -> String {
        switch choice {
        case .none: "none"
        case .some(let value): Wrapped.name(for: value)
        }
    }
}
