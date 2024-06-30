import XCTest
import SwiftDependencyContainer
import SwiftDependencyContainerMacros
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxBuilder
import SwiftParser
import SwiftSyntaxMacrosTestSupport

let testMacros: [String: Macro.Type] = [
    "Singelton": SingletonMacro.self,
]

final class MacroTests: XCTestCase {
    func test_singletonWithNoTypesMacro() throws {
        assertMacroExpansion(
            """
            @Singleton
            class MyClass {}
            """,
            expandedSource: """
            /// @Singleton
            class Class {}
            """,
            macros: testMacros
        )
        
        let source = """
        @Singleton
        class MyClass {}
        """

        let expectedOutput = """
        /// @Singleton
        class Class {}
        """
        
        // Parse the source code
        let sourceFile = Parser.parse(source: source)

        // Expand the macros
        let expanded = try expandMacros(in: sourceFile)
        
        XCTAssertFalse(source == expanded)
        XCTAssertEqual(expanded, expectedOutput)
    }
    
    private func expandMacros(in sourceFile: SourceFileSyntax) throws -> String {
        var context = BasicMacroExpansionContext(
            sourceFiles: [
                sourceFile: .init(moduleName: "SwiftDependencyContainerTests", fullFilePath: "MacroTests.swift")
            ]
        )
        
        return sourceFile.expand(macros: ["Singleton": SingletonMacro.self], in: context).description // .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
