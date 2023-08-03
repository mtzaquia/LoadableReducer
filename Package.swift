// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoadableReducer",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "LoadableReducer",
            targets: ["LoadableReducer"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .exact("1.0.0")
        ),
    ],
    targets: [
        .target(
            name: "LoadableReducer",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                )
            ]
        )
    ]
)
