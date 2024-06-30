// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SwiftDependencyContainer",
    platforms: [.iOS(.v15), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "SwiftDependencyContainer", targets: ["SwiftDependencyContainer"]),
        .plugin(name: "SwiftDependencyContainerPlugin", targets: ["SwiftDependencyContainerPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .macro(
            name: "SwiftDependencyContainerMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "SwiftDependencyContainer",
            dependencies: [
                "SwiftDependencyContainerMacros",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]),
        .testTarget(
            name: "SwiftDependencyContainerTests",
            dependencies: ["SwiftDependencyContainer"]),
        .plugin(
            name: "SwiftDependencyContainerPlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "SwiftDependencyContainerSourcery")
            ]
        ),
        .binaryTarget(
            name: "SwiftDependencyContainerSourcery",
            path: "Binaries/sourcery.artifactbundle"
        )
    ]
)
