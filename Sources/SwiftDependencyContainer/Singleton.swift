import Foundation

@attached(member)
public macro Singleton(_ type: Any... = []) = #externalMacro(module: "SwiftDependencyContainerMacros", type: "SingletonMacro")
