![Supports iOS](https://img.shields.io/badge/iOS-Supported-blue.svg)
![Supports macOS](https://img.shields.io/badge/macOS-Supported-blue.svg)
![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-green)

# Code Generation powered Dependency Container

`SwiftDependencyContainer` is a lightweight Dependency Container leveraging code generation to make setting up and managing dependencies easier than ever.

## Features

#### - Life Cycles

Objects registered as `Singleton` are retained throughout the container's' lifetime, once resolved. Marked as eager will create the instance immediately, when the `bootstrap` method is called. Objects registered as `Factory` will return a new instance every time it's being resolved.

#### - Auto-wiring

Required dependencies to instantiate an object using constructor injection can be auto-wired, assuming they are registered in the container.

#### - Type forwarding

Register one instance for multiple types, allowing for more flexible and maintainable code.

#### - Named definitions

Manage dependencies using hashable keys, enabling registering different implementations for the same protocol or tpye.

## Auto-Setup
 
For a magical setup experience thanks to code generation.

[Examples](Examples.swift) contains a demonstration for each use case. 

### Step 1: Annotate your Dependencies

You can use the following annotiations for automatic dependency resolution:

```swift
/// @Singleton
/// @EagerSingleton
/// @Singleton(types: [])
/// @EagerSingleton(types: [])
/// @Factory
```

### Step 2: Create a Composition Root

This is the entry point of your depdencies. 

All it takes is an object that confirms to the `AutoSetup` protocol.

```swift
import SwiftDependencyContainer

struct MyDependencies: AutoSetup {
    let container = DependencyContainer()
}
```

### Step 3: Bootstrap your Dependencies

After building your project, all necessary code for registering and resolving dependencies will be automatically generated and available.

To bootstrap your `DependencyContainer` call the `setup` method of your type implementing `AutoSetup`.

```swift
MyDependencies.setup()
```

Note: You won't be able to register any more dependencies after `setup` has been called.

### Step 4: Access your Dependencies

At this point you are ready to go. No more code that needs to be written!

There are two ways to access your dependencies:

```swift
/// @Singleton
class MyType {}
```

**Direct Access**

All your dependencies have a `resolve` method, which can be used to get the instance from the `DependencyContainer`.

```swift
MyType.resolve() // generated
```

**Composition Root Access**

Every registered dependency is also available as `static var` at your type implementing `AutoSetup`.

```swift
MyDependencies.myType // generated
```

### Step 5 (Optional): Manually register Dependencies

`AutoSetup` is great and convinient, but some scenarios require more flexibility.

Manually register dependencies if needed by overrideing the optional `override` method of the `AutoSetup` protocol.

```swift
struct MyDependencies: AutoSetup {
    let container = DependencyContainer()
    
    func override(_ container: DependencyContainer) throws {
        try container.register(Storage.self) { UserDefaults() } // register
    }
    
    static var storage: Storage { resolve() } // resolve
}
```

Note: Please feel free to open a ticket if you feel like the usage of your `override` should be part of this framework!

Take a look at [Examples](Examples.swift) for more details.

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

## Installation

### 1. Add Swift Package
You can use the [Swift Package Manager](https://swift.org/package-manager/) to install `SwiftDependencyContainer` by adding it as a dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "git@github.com:davidscheutz/SwiftDependencyContainer.git", from: "0.2.0")
]
```

Make sure to add `SwiftDependencyContainer` as a dependency to your Target.

### 2. Add SwiftDependencyContainer CodeGeneratorPlugin as Build Tool Plugin

Select your Project -> Your Target -> Build Phases -> Add CodeGeneratorPlugin (SwiftDependencyContainer)

The codegen runs now as part of the build phase, every time you compile your project. 

## Contributing

Contributions to `SwiftDependencyContainer` are welcomed and encouraged!

It is easy to get involved. Open an issue to discuss a new feature, write clean code, show some love using unit tests and open a Pull Request.

A list of contributors will be available through GitHub.

PS: Check the open issues and pull requests for existing discussions.

## License

`SwiftDependencyContainer` is available under the MIT license.

## Credit

This project uses [Sourcery](https://github.com/krzysztofzablocki/Sourcery) for the code generation.
