import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SwiftDependencyContainerMacroPlugin)
import SwiftDependencyContainerMacroPlugin

let testMacros: [String: Macro.Type] = [
    "Singleton": SingletonMacro.self
]
#endif

final class SwiftDependencyContainerMacroPluginTests: XCTestCase {
    func test() throws {
        #if canImport(SwiftDependencyContainerMacroPlugin)
        assertMacroExpansion("""
            @Singleton
            class MyClass() {}
            """,
            expandedSource: """
            /// cool
            @Singleton
            class MyClass() {}
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
