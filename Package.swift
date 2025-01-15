// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "ZXCatalog",
    defaultLocalization: LanguageTag("en"),
    platforms: [.iOS(.v16), .macOS(.v10_15)],
    products: [
        .library(name: "ZXCatalog", targets: ["ZXCatalog"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", from: "0.57.1"),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", from: "5.3.0"),

        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", exact: "0.5.2"),
    ],
    targets: [
        .target(
            name: "ZXCatalog",
            dependencies: [
                "ZXCatalogMacros",
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols")
            ],
            resources: [.process("Resources")],
            swiftSettings: [
                .unsafeFlags(["-emit-extension-block-symbols"]),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        .macro(
            name: "ZXCatalogMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "ZXCatalogMacrosTests",
            dependencies: [
                "ZXCatalogMacros",
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        )
    ]
)
