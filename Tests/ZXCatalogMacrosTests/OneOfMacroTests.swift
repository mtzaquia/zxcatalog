//
// Created by Mauricio Tremea Zaquia
// Copyright ® 2025 Mauricio Tremea Zaquia. All rights reserved.
//

import XCTest
import MacroTesting
import ZXCatalogMacros

final class OneOfMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
//            record: true,
            macros: ["OneOf": OneOfMacro.self]
        ) {
            super.invokeTest()
        }
    }

    func test_oneOfMacro_basic() async throws {
        assertMacro {
          """
          @OneOf
          public enum Content {
              case text(_ text: String, icon: AssetName? = nil, iconPosition: IconPosition = .start)
              case icon(_ icon: AssetName, accessibilityLabel: String)
          }
          """
        } expansion: {
            """
            public enum Content {
                case text(_ text: String, icon: AssetName? = nil, iconPosition: IconPosition = .start)
                case icon(_ icon: AssetName, accessibilityLabel: String)

                public enum BindingCases {
                    case text(Binding<String>, icon: Binding<AssetName?>, iconPosition: Binding<IconPosition>)
                    case icon(Binding<AssetName>, accessibilityLabel: Binding<String>)
                }

                public static func binding(mutating choice: Binding<Self>) -> BindingCases {
                    switch choice.wrappedValue {
                    case let .text(_0, _1, _2):
                        .text(Binding<String>(get: {
                                    _0
                                }, set: {
                                    choice.wrappedValue = .text($0, icon: _1, iconPosition: _2)
                                }), icon: Binding<AssetName?>(get: {
                                    _1
                                }, set: {
                                    choice.wrappedValue = .text(_0, icon: $0, iconPosition: _2)
                                }), iconPosition: Binding<IconPosition>(get: {
                                    _2
                                }, set: {
                                    choice.wrappedValue = .text(_0, icon: _1, iconPosition: $0)
                                }))
                    case let .icon(_0, _1):
                        .icon(Binding<AssetName>(get: {
                                    _0
                                }, set: {
                                    choice.wrappedValue = .icon($0, accessibilityLabel: _1)
                                }), accessibilityLabel: Binding<String>(get: {
                                    _1
                                }, set: {
                                    choice.wrappedValue = .icon(_0, accessibilityLabel: $0)
                                }))
                    }
                }

                public enum Cases: Hashable, CaseIterable {
                    case text
                    case icon
                }

                public var choice: Cases {
                    get {
                        switch self {
                        case .text:
                            .text
                        case .icon:
                            .icon
                        }
                    }
                    mutating set {
                        self = Self.`default`(for: newValue)
                    }
                }
            }

            extension Content: ZXCatalog.OneOf {
            }
            """
        }
    }

    func test_oneOfMacro_mixed() async throws {
        assertMacro {
          """
          @OneOf
          public enum Selection {
              case trailing(icon: AssetName)
              case none
          }
          """
        } expansion: {
            """
            public enum Selection {
                case trailing(icon: AssetName)
                case none

                public enum BindingCases {
                    case trailing(icon: Binding<AssetName>)
                    case none
                }

                public static func binding(mutating choice: Binding<Self>) -> BindingCases {
                    switch choice.wrappedValue {
                    case let .trailing(_0):
                        .trailing(icon: Binding<AssetName>(get: {
                                    _0
                                }, set: {
                                    choice.wrappedValue = .trailing(icon: $0)
                                }))
                    case .none:
                        .none
                    }
                }

                public enum Cases: Hashable, CaseIterable {
                    case trailing
                    case none
                }

                public var choice: Cases {
                    get {
                        switch self {
                        case .trailing:
                            .trailing
                        case .none:
                            .none
                        }
                    }
                    mutating set {
                        self = Self.`default`(for: newValue)
                    }
                }
            }

            extension Selection: ZXCatalog.OneOf {
            }
            """
        }
    }

    func test_oneOfMacro_plain() async throws {
        assertMacro {
          """
          @OneOf
          public enum Position {
              case top
              case bottom
          }
          """
        } expansion: {
            """
            public enum Position {
                case top
                case bottom

                public enum BindingCases {
                    case top
                    case bottom
                }

                public static func binding(mutating choice: Binding<Self>) -> BindingCases {
                    switch choice.wrappedValue {
                    case .top:
                        .top
                    case .bottom:
                        .bottom
                    }
                }

                public enum Cases: Hashable, CaseIterable {
                    case top
                    case bottom
                }

                public var choice: Cases {
                    get {
                        switch self {
                        case .top:
                            .top
                        case .bottom:
                            .bottom
                        }
                    }
                    mutating set {
                        self = Self.`default`(for: newValue)
                    }
                }
            }

            extension Position: ZXCatalog.OneOf {
            }
            """
        }
    }

    func test_oneOfMacro_notEnum() async throws {
        assertMacro {
          """
          @OneOf
          public struct Content {
              let sample: String
          }
          """
        } diagnostics: {
            """
            @OneOf
            ╰─ 🛑 `@OneOf` is only valid for enumerations.
               ✏️ Remove `@OneOf`
            public struct Content {
                let sample: String
            }
            """
        }fixes: {
            """
            public struct Content {
                let sample: String
            }
            """
        } expansion: {
            """
            public struct Content {
                let sample: String
            }
            """
        }
    }
}
