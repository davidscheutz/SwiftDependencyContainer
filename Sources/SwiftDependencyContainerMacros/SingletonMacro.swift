import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct SingletonMacro: MemberMacro {
    
    /*
     Types conforming to `MemberMacro` must implement either expansion(of:providingMembersOf:in:) or expansion(of:providingMembersOf:conformingTo:in:)
     @Singleton
     */
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
      ) throws -> [DeclSyntax] {
          return []
      }
    
    public static func expansion(
            of node: DeclSyntax,
            attachedTo declaration: DeclSyntax,
            in context: MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
    
    public static func expansion(
        of node: DeclSyntax,
        in context: MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = node.as(ClassDeclSyntax.self) else {
            return []
        }
        
        let comment: String
        
        if let args = classDecl.attributes.first(where: { $0.as(AttributeSyntax.self)?.attributeName == "Singleton" })?.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self),
           let firstArg = args.first {
            let argType = firstArg.expression.description.trimmingCharacters(in: .whitespaces)
            comment = "/// @Singleton(\(argType))"
        } else {
            comment = "/// @Singleton"
        }
        
        let leadingTrivia = Trivia(pieces: [.lineComment(comment), .newlines(1)])
        let commentedClassDecl = classDecl.withLeadingTrivia(leadingTrivia)
        
        return [DeclSyntax(commentedClassDecl)]
    }
}

private extension SyntaxProtocol {
    func withLeadingTrivia(_ trivia: Trivia) -> Self {
        return with(\.leadingTrivia, trivia)
    }
}
