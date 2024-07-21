/// Declares a function that can be used to register the specific type within the dependency container.
///
/// A `@Singleton` autogenerates the code to register and resolve a single instance of that specific type.
///
///
/// - Parameters:
///   - isEager: Specifies whether the instance will be resolved during the bootstrapping of the dependency container or once accessed.
///   - types: Specifies the types that the instance will be registered with. If the parameter isn't provided, the instance type will be used.
@attached(peer, names: named(Singleton))
public macro Singleton(
    isEager: Bool = false,
    _ types: Any.Type... = []
) = #externalMacro(module: "SwiftDependencyContainerMacroPlugin", type: "SingletonMacro")
