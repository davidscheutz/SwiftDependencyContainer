import Foundation
import PackagePlugin

@main
struct SwiftDependencyContainerPlugin: BuildToolPlugin {
    func createBuildCommands (context: PluginContext, target: Target) throws -> [Command] {
        []
    }
}

#if canImport (XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftDependencyContainerPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
        try sourcery(target: target, in: context)
    }
    
    private func sourcery(target: XcodeProjectPlugin.XcodeTarget, in context: XcodeProjectPlugin.XcodePluginContext) throws -> [Command] {
        let toolPath = try context.tool(named: "sourcery")
        let templatesPath = toolPath.path.removingLastComponent().removingLastComponent().appending("Templates")
        let imports = context.xcodeProject.targets
            .filter { $0.product?.isImportable == true && $0.displayName != target.displayName }
            .map { "\"\($0.displayName)\"" }
            .joined(separator: ",")
        
        let targetCommand = command(
            for: target,
            isGlobal: false,
            imports: "\"\(target.displayName)\"",
            executable: toolPath.path,
            templates: templatesPath,
            root: context.xcodeProject.directory,
            output: context.pluginWorkDirectory
        )
        
        return target.product?.isApp == true ? [
            command(
                for: target,
                isGlobal: true,
                imports: imports,
                executable: toolPath.path,
                templates: templatesPath,
                root: context.xcodeProject.directory,
                output: context.pluginWorkDirectory
            ),
            targetCommand
        ] : [targetCommand]
    }
    
    private func command(
        for target: XcodeTarget,
        isGlobal: Bool,
        imports: String,
        executable: Path,
        templates: Path,
        root: Path,
        output: Path
    ) -> Command {
        let targetOutput = output.appending(subpath: isGlobal ? "Global" : "Target")
        
        return Command.prebuildCommand(
            displayName: "SwiftDependencyContainer generate: \(target.displayName) - Global: \(isGlobal)",
            executable: executable,
            arguments: [
                "--templates",
                templates.appending(subpath: isGlobal ? "Global" : "Target"),
                "--args",
                "imports=[\(imports)]",
                "--args",
                "target=\(target.displayName)",
                "--sources",
                isGlobal ? root : root.appending(subpath: target.displayName),
                "--output",
                targetOutput,
                "--parseDocumentation",
                "--disableCache",
                "--verbose"
            ].compactMap { $0 },
            environment: [:],
            outputFilesDirectory: targetOutput
        )
    }
}

extension XcodeProduct {
    var isApp: Bool {
        switch kind {
        case .application:
            return true
        case .executable, .framework, .library, .other(_):
            return false
        @unknown default:
            return false
        }
    }
    
    var isImportable: Bool {
        switch kind {
        case .application, .framework, .library:
            return true
        case .executable, .other(_):
            return false
        @unknown default:
            return false
        }
    }
}

#endif
