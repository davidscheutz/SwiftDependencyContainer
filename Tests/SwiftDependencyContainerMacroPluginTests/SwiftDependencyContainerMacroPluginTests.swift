import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SwiftDependencyContainerMacroPlugin)
import SwiftDependencyContainerMacroPlugin
#endif

final class SwiftDependencyContainerMacroPluginTests: XCTestCase {
    func test_emptySingletonMacro() throws {
        #if canImport(SwiftDependencyContainerMacroPlugin)
        assertMacroExpansion("""
            @Singleton
            class MyClass {}
            """,
            expandedSource: """
            class MyClass {}
            """,
            macros: ["Singleton": SingletonMacro.self]
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_emptyFactoryMacro() throws {
        #if canImport(SwiftDependencyContainerMacroPlugin)
        assertMacroExpansion("""
            @Factory
            class MyClass {}
            """,
            expandedSource: """
            class MyClass {}
            """,
            macros: ["Factory": FactoryMacro.self]
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_emptyAliasMacro() throws {
        #if canImport(SwiftDependencyContainerMacroPlugin)
        assertMacroExpansion("""
            @Alias
            class MyClass {}
            """,
            expandedSource: """
            class MyClass {}
            """,
            macros: ["Alias": AliasMacro.self]
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
