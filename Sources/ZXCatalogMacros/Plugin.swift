//
// Created by Mauricio Tremea Zaquia
// Copyright ® 2025 Mauricio Tremea Zaquia. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ZXFoundationsMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        OneOfMacro.self,
    ]
}
