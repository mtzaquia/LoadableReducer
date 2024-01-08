// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "LoadableReducer",
    platforms: [
        .iOS(.v14),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "LoadableReducer",
            targets: ["LoadableReducer"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "1.5.1"
        ),
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.2.0")
    ],
    targets: [
        .target(
            name: "LoadableReducer",
            dependencies: [
                "LoadableReducerMacros",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                )
            ]
        ),
        .testTarget(
            name: "LoadableReducerTests",
            dependencies: [
                "LoadableReducer"
            ]
        ),

        .macro(
            name: "LoadableReducerMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "LoadableReducerMacrosTests",
            dependencies: [
                "LoadableReducerMacros",
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
    ]
)

