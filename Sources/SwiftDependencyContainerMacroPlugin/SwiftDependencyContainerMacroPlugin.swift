import SwiftCompilerPlugin
import SwiftSyntaxMacros
import Foundation

@main
struct SwiftDependencyContainerMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SingletonMacro.self
    ]
}
