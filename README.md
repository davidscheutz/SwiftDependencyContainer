![Supports iOS](https://img.shields.io/badge/iOS-Supported-blue.svg)
![Supports macOS](https://img.shields.io/badge/macOS-Supported-blue.svg)
![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-green)

# Code Generation powered Dependency Container

`SwiftDependencyContainer` is a lightweight Dependency Container leveraging [Swift Macros](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/) and code generation to make setting up and managing dependencies easier than ever.

## Features

#### - Life Cycles

**Singleton** objects are retained throughout the container's' lifetime. They are instantiated on demand when first accessed, or, if marked as `eager`, created when the container is bootstrapped.

**Factory** instances of the registered type are created each time they are resolved.

#### - Auto-wiring

Dependencies required to instantiate an object using constructor injection are automatically resolved, provided they are registered in the container.

#### - Type forwarding

Register a single instance for multiple types, allowing for more flexible and maintainable code.

#### - Named definitions

Manage dependencies with hashable keys, enabling the registration of different implementations for the same protocol or tpye.

## Installation

### 1. Add Swift Package
You can use the [Swift Package Manager](https://swift.org/package-manager/) to install `SwiftDependencyContainer` by adding it as a dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "git@github.com:davidscheutz/SwiftDependencyContainer.git", from: "0.5.0")
]
```

Make sure to add `SwiftDependencyContainer` as a dependency to your Target.

### 2. Add SwiftDependencyContainer CodeGeneratorPlugin as Build Tool Plugin

Select your Project -> Your Target -> Build Phases -> Add CodeGeneratorPlugin (SwiftDependencyContainer)

The code generation process now runs automatically during the build phase, every time you compile your project.

## Auto-Setup 🪄
 
For a magical setup experience thanks to code generation.

[Examples](Examples.swift) demonstrate each use case. 

### Step 1: Register your Dependencies

Use the following annotiations to register your dependencies:

```swift
@Singleton
@Singleton(isEager: true)       // Instantiated when container is bootstrapped rather than at first access
@Singleton(MyProtocol.self)     // Register dependency for additional types
class MyClass {
    init(otherDependency: OtherClass) {} // Auto-inject supported
}
```

```swift
@Factory
class MyBuilder {
    init(otherDependency: OtherClass) {} // Auto-inject supported
}
```

### Step 2: Create a Composition Root

This is the entry point of your depdencies. 

Simply define an object that conforms to the `AutoSetup` protocol.

```swift
import SwiftDependencyContainer

struct MyDependencies: AutoSetup {
    let container = DependencyContainer()
}
```

### Step 3: Bootstrap your Dependencies

Once your project is built, the necessary code for registering and resolving dependencies will be automatically generated and ready to use.

To bootstrap your `DependencyContainer` call the `setup` method on your type that implements the `AutoSetup` protocol.

```swift
MyDependencies.setup()
```

Note: After calling `setup`, you will no longer be able to register additional dependencies.

### Step 4: Access your Dependencies

At this stage, you're all set! No additional code is required to use your dependencies.

You can access your dependencies in two ways:

**Direct Access**

Use the `resolve` method of a registered type to retrieve an instance from the `DependencyContainer`.

```swift
MyType.resolve() // Auto-generated
```

**Composition Root Access**

Access any registered dependency as a `static var` from your type implementing `AutoSetup`:

```swift
MyDependencies.myType // Auto-generated
```

### Step 5 (Optional): Manually register Dependencies

While `AutoSetup` is convenient, some scenarios may require additional flexibility. In such cases, you can manually register additional dependencies by overriding the optional `override` method of the `AutoSetup` protocol.

```swift
struct MyDependencies: AutoSetup {
    let container = DependencyContainer()
    
    func override(_ container: DependencyContainer) throws {
        try container.register(Storage.self) { UserDefaults() } // e.g. Register third-party SDKs
    }
    
    static var storage: Storage { resolve() } // Mimic API of auto-generated types
}
```

Note: Please feel free to open a ticket if you feel like the usage of your `override` should be part of this framework!
Note: If you have a repetitive use case and believe it should be integrated into this framework, feel free to open a ticket!

For more details, check out the [Examples](Examples.swift).

## Manual-Setup

For those who prefer the traditional way:

### Step 1: Create your `DependencyContainer`

```swift
let container = DependencyContainer()
```

### Step 2: Register your Dependencies

```swift
try container.register { Singleton1() }

// resolve other co-dependencies 
try container.register { Singleton2(other: try $0.resolve()) }

// register instance for another type
try container.register(Abstraction.self) { Singleton1() }

// register instance for several other types
try container.register([Abstraction1.self, Abstraction2.self]) { Singleton1() }

// register instance for a key
try container.register("MyKey") { Singleton1() }
```

All `register` methods include an `isEager: Bool` parameter. Eager dependencies are resolved upon container bootstrap.

Note: Keys are required to be `Hashable`.

### Step 3: Bootstrap your Dependencies

```swift
try container.bootstrap()
```

### Step 4: Resolve your Dependencies

```swift
let singleton: Singleton1 = try container.resolve()

let singleton1: Singleton1 = try container.resolve("MyKey")

let singleton2: Abstraction2 = try container.resolve()
```

## Contributing

Contributions to `SwiftDependencyContainer` are welcomed and encouraged!

It is easy to get involved. Open an issue to discuss a new feature, write clean code, show some love using unit tests and open a Pull Request.

A list of contributors will be available through GitHub.

PS: Check the open issues and pull requests for existing discussions.

## License

`SwiftDependencyContainer` is available under the MIT license.

## Credit

This project uses [Sourcery](https://github.com/krzysztofzablocki/Sourcery) for the code generation.
