import SwiftDependencyContainer

// ------------------ SETUP ------------------ //

struct ExampleDependencies: AutoSetup {
    // Your dependencies will live here
    let container: DependencyContainer
}

/*
    😎 That's all we have to do, isn't that magical?
 
    There are two types of dependencies to choose from:
 
    - Singleton
        The instance is created the moment it's being resolved for the
        first time and exists throughout the lifetime of your app.
 
    - Factory
        A new instance is created every time it's being resolved.
 */


// ------------------ SINGLETON ------------------ //

/* REGISTER */

    /// @Singleton
    class SimpleClass {}

    /// @EagerSingleton
    class EagerSimpleClass {
        // wil be instantiated on app creation
    }

    protocol Abstraction {}

    /// @Singleton(types: [Abstraction])
    class Implementation: Abstraction {}#

    /// @Singleton
    class DependingClass {
        init(simpleClass: SimpleClass) {}
    }

/* USAGE */

    // Access a dependency using the dependencies host
    _ = ExampleDependencies.simpleClass

    // Access a dependency directly
    _ = SimpleClass.resolve()

    // Dependencies registered for a specific type inherit the name of that type
    _ = ExampleDependencies.abstraction
    _ = Implementation.resolveAbstraction()

    // Dependencies are resolved automatically
    _ = ExampleDependencies.dependingClass
    _ = DependingClass.resolve()


// ------------------ FACTORY ------------------ //

/* REGISTER */

    /// @Factory
    class SimpleBuilder {}

    /* REGISTER */

    /// @Factory
    class DependingBuilder {
        init(simpleClass: SimpleClass) {}
    }

    /// @Factory
    class ConfigurableBuilder {
        init(id: String) {}
    }

/* USAGE */

    _ = ExampleDependencies.createSimpleBuilder()

    // Dependencies are resolved automatically
    _ = ExampleDependencies.createDependingBuilder()

    _ = ExampleDependencies.createConfigurableBuilder(id: "My ID")
