//
// Created by Mauricio Tremea Zaquia
// Copyright ® 2025 Mauricio Tremea Zaquia. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

private let packageName = "ZXCatalog"
private let casesTypeName = "Cases"

public struct OneOfMacro {
    private static let protocolName = "OneOf"
}

extension OneOfMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(EnumDeclSyntax.self) else {
            context.diagnose(
                .init(
                    node: declaration,
                    message: MacroExpansionErrorMessage("`@OneOf` is only valid for enumerations."),
                    fixIt: .replace(
                        message: MacroExpansionFixItMessage("Remove `@OneOf`"),
                        oldNode: node,
                        newNode: DeclSyntax("")
                    )
                )
            )
            
            return []
        }

        if declaration.memberBlock.hasEnum(named: casesTypeName) {
            return []
        }

        let access = declaration.modifiers.first {
            [.keyword(.public), .keyword(.package)].contains($0.name.tokenKind)
        }

        var enumCases = [EnumCase]()

        for member in declaration.memberBlock.members {
            guard let enumCase = member.decl.as(EnumCaseDeclSyntax.self) else { continue }

            for element in enumCase.elements {
                let caseName = element.name.text
                var parametersList = [CaseParam]()

                if let parameters = element.parameterClause?.parameters, !parameters.isEmpty {
                    for parameter in parameters {
                        let parameterName = parameter.firstName?.text ?? parameter.secondName?.text

                        let parameterType = parameter.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !parameterType.hasPrefix("Binding<") {
                            parametersList.append(
                                CaseParam(name: parameterName, type: "Binding<\(parameterType)>")
                            )
                        } else {
                            parametersList.append(
                                CaseParam(name: parameterName, type: parameterType)
                            )
                        }
                    }
                }

                enumCases.append(EnumCase(name: caseName, params: parametersList))
            }
        }

        let plainCases = enumCases.cases(renderingMode: .justCase)
        let bindingCases = enumCases.cases(renderingMode: .caseWithAssociatedValues)
        let patternMatchedCases = zip(
            enumCases.cases(renderingMode: .patternMatching),
            enumCases.cases(renderingMode: .caseExpressionWithBindings)
        ).map { [$0, $1].joined(separator: "\n") }

        let casesEnumSyntax: DeclSyntax =
            """
            \(access)enum Cases: Hashable, CaseIterable {
                \(raw: plainCases.joined(separator: "\n"))
            }
            """

        let bindingCasesEnumSyntax: DeclSyntax =
            """
            \(access)enum BindingCases {
                \(raw: bindingCases.joined(separator: "\n"))
            }
            """

        let bindingVariableSyntax: DeclSyntax =
            """
            \(access)static func binding(mutating choice: Binding<Self>) -> BindingCases {
                switch choice.wrappedValue {
                \(raw: patternMatchedCases.joined(separator: "\n"))
                }
            }
            """

        let choiceVariableSyntax: DeclSyntax =
            """
            \(access)var choice: Cases { 
                get { 
                    switch self {
                    \(raw: enumCases.map { "case .\($0.name): .\($0.name)" }.joined(separator: "\n")) 
                    }
                }
                mutating set { self = Self.`default`(for: newValue) }
            }
            """

        return [
            bindingCasesEnumSyntax,
            bindingVariableSyntax,
            casesEnumSyntax,
            choiceVariableSyntax
        ]
    }
}

extension OneOfMacro: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard declaration.is(EnumDeclSyntax.self) else {
            return []
        }

        if declaration.inheritanceClause?.inheritedTypes.conformsTo(protocolName) == true {
            return []
        }

        let proto = "\(packageName).\(protocolName)"
        let ext: DeclSyntax =
          """
          \(declaration.attributes.availability)extension \(type.trimmed): \(raw: proto) {}
          """

        return [ext.cast(ExtensionDeclSyntax.self)]
    }
}

private extension InheritedTypeListSyntax {
    func conformsTo(_ protocolName: String) -> Bool {
        contains(where: {
            [protocolName, "\(packageName).\(protocolName)"].contains($0.type.trimmedDescription)
        })
    }
}

private extension MemberBlockSyntax {
    func hasEnum(named name: String) -> Bool {
        members.contains(where: {
            guard let nestedEnum = $0.decl.as(EnumDeclSyntax.self) else {
                return false
            }

            return nestedEnum.name.text == casesTypeName
        })
    }
}

private extension AttributeListSyntax {
    var availability: AttributeListSyntax? {
        var elements = [AttributeListSyntax.Element]()
        for element in self {
            if let availability = element.availability {
                elements.append(availability)
            }
        }
        if elements.isEmpty {
            return nil
        }
        return AttributeListSyntax(elements)
    }
}

private extension AttributeListSyntax.Element {
    var availability: AttributeListSyntax.Element? {
        switch self {
        case .attribute(let attribute):
            if let availability = attribute.availability {
                return .attribute(availability)
            }
        case .ifConfigDecl(let ifConfig):
            if let availability = ifConfig.availability {
                return .ifConfigDecl(availability)
            }
        }
        return nil
    }
}

private extension AttributeSyntax {
    var availability: AttributeSyntax? {
        if attributeName.identifier == "available" {
            return self
        } else {
            return nil
        }
    }
}

private extension IfConfigDeclSyntax {
    var availability: IfConfigDeclSyntax? {
        var elements = [IfConfigClauseListSyntax.Element]()
        for clause in clauses {
            if let availability = clause.availability {
                if elements.isEmpty {
                    elements.append(availability.clonedAsIf)
                } else {
                    elements.append(availability)
                }
            }
        }

        if elements.isEmpty {
            return nil
        } else {
            return with(\.clauses, IfConfigClauseListSyntax(elements))
        }
    }
}

private extension IfConfigClauseSyntax {
    var availability: IfConfigClauseSyntax? {
        if let availability = elements?.availability {
            return with(\.elements, availability)
        } else {
            return nil
        }
    }

    var clonedAsIf: IfConfigClauseSyntax {
        detached.with(\.poundKeyword, .poundIfToken())
    }
}

private extension IfConfigClauseSyntax.Elements {
    var availability: IfConfigClauseSyntax.Elements? {
        switch self {
        case .attributes(let attributes):
            if let availability = attributes.availability {
                return .attributes(availability)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

private extension TypeSyntax {
    var identifier: String? {
        for token in tokens(viewMode: .all) {
            switch token.tokenKind {
            case .identifier(let identifier):
                return identifier
            default:
                break
            }
        }
        return nil
    }
}

private struct EnumCase {
    let name: String
    let params: [CaseParam]
}

private struct CaseParam {
    let name: String?
    let type: String
}

private enum CaseRenderingMode {
    case patternMatching
    case justCase
    case caseWithAssociatedValues
    case caseExpressionWithBindings
}

private extension [EnumCase] {
    func cases(renderingMode: CaseRenderingMode) -> [String] {
        map { oneCase in
            switch renderingMode {
            case .patternMatching:
                let params = oneCase.params.parameters(renderingMode: .typedWithLabel)
                    .enumerated()
                    .map { idx, _ in "_\(idx)" }
                    .joined(separator: ", ")

                return "case \(params.isEmpty ? "" : "let ").\(oneCase.name)\(params.isEmpty ? "" : "(\(params))"):"

            case .justCase:
                return "case \(oneCase.name)"

            case .caseWithAssociatedValues:
                let params = oneCase.params.parameters(renderingMode: .typedWithLabel).joined(separator: ", ")
                return "case \(oneCase.name)\(params.isEmpty ? "" : "(\(params))")"

            case .caseExpressionWithBindings:
                let params = oneCase.params.parameters(renderingMode: .labelledBinding(caseName: oneCase.name))
                    .joined(separator: ", ")

                return ".\(oneCase.name)\(params.isEmpty ? "" : "(\(params))")"
            }
        }
    }
}

private enum CaseParameterRenderingMode {
    case typedWithLabel
    case typedWithAnonymous(anonymousIndex: Int)
    case labelledBinding(caseName: String)
}

private extension [CaseParam] {
    func parameters(renderingMode: CaseParameterRenderingMode) -> [String] {
        self
            .enumerated()
            .map { index, value in
            switch renderingMode {
            case .typedWithLabel:
                if let label = value.name, label != "_" {
                    return "\(label): \(value.type)"
                } else {
                    return value.type
                }

            case .typedWithAnonymous(let anonymousIndex):
                let input = anonymousIndex == index ? "$0" : "_\(index)"
                if let label = value.name, label != "_" {
                    return "\(label): \(input)"
                } else {
                    return input
                }

            case .labelledBinding(let caseName):
                let bindingParameters = parameters(renderingMode: .typedWithAnonymous(anonymousIndex: index))
                    .joined(separator: ", ")
                let binding = "\(value.type)(get: { _\(index) }, set: { choice.wrappedValue = .\(caseName)(\(bindingParameters)) })"
                if let label = value.name, label != "_" {
                    return "\(label): \(binding)"
                } else {
                    return binding
                }
            }
        }
    }
}
