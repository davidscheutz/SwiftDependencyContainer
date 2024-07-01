// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SwiftDependencyContainer",
    platforms: [.iOS(.v12), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "SwiftDependencyContainer", targets: ["SwiftDependencyContainer"]),
        .plugin(name: "SwiftDependencyContainerPlugin", targets: ["SwiftDependencyContainerPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftDependencyContainer",
            dependencies: ["SwiftDependencyContainerMacroPlugin"]
        ),
        .testTarget(
            name: "SwiftDependencyContainerTests",
            dependencies: ["SwiftDependencyContainer"]
        ),
        .macro(
            name: "SwiftDependencyContainerMacroPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "SwiftDependencyContainerMacroPluginTests",
            dependencies: [
                "SwiftDependencyContainerMacroPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
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
