import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

enum SingletonAttributeParser {
    static func parse(
        attribute: AttributeSyntax,
        context: some MacroExpansionContext
    ) -> SingletonAttribute {
        var returnType: String? = nil
        var named: String? = nil
        
        attribute.arguments?.as(LabeledExprListSyntax.self)?.forEach { labeledExpr in
            switch labeledExpr.label?.text {
            case "types":
                print(labeledExpr.expression)
//            case "of":
//                returnType = MetatypeParser.parse(expression: labeledExpr.expression)
//            case "scope":
//                guard
//                    let expression = labeledExpr.expression.as(MemberAccessExprSyntax.self),
//                    let scopeCase = Scope(rawValue: expression.declName.baseName.text)
//                else {
//                    context.diagnose(
//                        node: labeledExpr,
//                        message: .invalidScope
//                    )
//                    return
//                }
//                scope = scopeCase
//            case "named":
//                named = labeledExpr.expression.description.trimmed()
            default: break
            }
        }

        return SingletonAttribute(types: [])
    }
}
