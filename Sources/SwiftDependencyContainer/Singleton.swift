/// Declares a function that can be used to register the specific type within the dependency container.
///
/// A `@Singleton` autogenerates the code to register and resolve a single instance of that specific type.
///
///
/// - Parameters:
///   - types: Specifies the types that the instance will be registered with. If the parameter isn't provided, the instance type will be used.
@attached(peer, names: named(_$Singleton))
public macro Singleton(
    _ types: Any.Type... = []
) = #externalMacro(module: "SwiftDependencyContainerMacroPlugin", type: "SingletonMacro")
