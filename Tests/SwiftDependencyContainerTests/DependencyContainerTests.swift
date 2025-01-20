import XCTest
import SwiftDependencyContainer

class DependencyContainerTests: XCTestCase {
    
    var sut: DependencyContainer!
    
    override func setUp() {
        sut = .init()
    }
    
    func test_bootstrapOnDemand() throws {
        try sut.registerSingletonImpl1WithKey()
        
        let start = Date()
        
        let singleton = try sut.resolveSingleton(.singleton1)
        
        XCTAssertTrue(start < singleton.created)
    }
    
    func test_eagerBootstrap() throws {
        try sut.registerSingletonImpl1WithKey(eager: true)
        
        try sut.bootstrap()
        
        let start = Date()
        
        let singleton = try sut.resolveSingleton(.singleton1)
        
        XCTAssertTrue(start > singleton.created)
    }
    
    func test_eagerWithoutBootstrap() throws {
        try sut.registerSingletonImpl1WithKey(eager: true)
                
        do {
            _ = try sut.resolveSingleton(.singleton1)
            XCTFail("Shouldn't be able to resolve a dependency before the container is bootstrapped")
        } catch let error {
            if case .notBootstrapped = error as? DependencyContainer.ResolveError<TestSingleton> {
                // expected
            } else {
                XCTFail("Unknown error: \(error)")
            }
        }
    }
    
    func test_singleInstance() throws {
        try sut.registerSingletonImpl1WithKey()
        
        XCTAssertTrue(try sut.resolveSingleton(.singleton1) === sut.resolveSingleton(.singleton1))
    }
    
    func test_replaceRegisteredInstanceBeforeBootstrap() throws {
        try sut.registerSingletonImpl1WithKey(id: "1")
        try sut.registerSingletonImpl1WithKey(id: "2")
        
        let result = try sut.resolveSingleton(.singleton1)
        XCTAssertEqual(result.id, "2")
    }
    
    func test_registerAfterEagerRegisterFails() throws {
        try sut.registerSingletonImpl1WithKey(eager: true)
        try sut.bootstrap()
        do {
            try sut.registerSingletonImpl1WithKey()
            XCTFail("Should fail, dependency for key is already bootstrapped.")
        } catch {}
    }
    
    func test_resolveWrongTypeFails() throws {
        try sut.register(for: .singleton1) { SingletonImpl1() }
        try sut.bootstrap()
        
        do {
            let _: SingletonImpl2 = try sut.resolve(using: .singleton1)
            XCTFail("Should fail, dependency type isn't matching.")
        } catch let error {
            if case .typeMismatch(actual: "SingletonImpl1") = error as? DependencyContainer.ResolveError<SingletonImpl2> {
                // expected
            } else {
                XCTFail("Unknown error: \(error)")
            }
        }
    }
    
    func test_resolveInnerDependencyFails() throws {
        try sut.register { SingletonImpl2(other: try $0.resolve()) }
        try sut.bootstrap()
        
        do {
            let _: SingletonImpl2 = try sut.resolve()
            XCTFail("Should fail, dependency instantiation failed.")
        } catch let error {
            if case .unknown = error as? DependencyContainer.ResolveError<SingletonImpl2> {
                // expected
            } else {
                XCTFail("Unknown error: \(error)")
            }
        }
    }
    
    func test_registerForEmptyTypesFails() throws {
        do {
            try sut.register([]) { SingletonImpl1() }
            XCTFail("Should fail, no type information provided.")
        } catch let error {
            if case .missingKey = error as? DependencyContainer.RegisterError {
                // expected
            } else {
                XCTFail("Unknown error: \(error)")
            }
        }
    }
    
    func test_registerAfterBootstrappedFails() throws {
        try sut.registerSingletonImpl1WithKey()
        
        try _ = sut.resolveSingleton(.singleton1)
        
        do {
            try sut.registerSingletonImpl1WithKey()
            XCTFail("Should fail, dependency for key was already resolved.")
        } catch {}
    }
    
    func test_registerUsingTypeinformation() throws {
        try sut.register(isEager: true) { SingletonImpl1() }
        
        try sut.register {
            let s1: SingletonImpl1 = try $0.resolve()
            return SingletonImpl2(other: s1)
        }
        
        try sut.bootstrap()
        
        let _: SingletonImpl1 = try sut.resolve()
        let _: SingletonImpl2 = try sut.resolve()
        
        let resolvedFailure: TestSingleton? = try? sut.resolve()
        XCTAssertNil(resolvedFailure)
    }
    
    func test_registerSameObjectTwiceFails() throws {
        try sut.register(isEager: true) { SingletonImpl1() }
        try sut.bootstrap()
        
        do {
            try sut.register { SingletonImpl1() }
            
            XCTFail("Shouldn't be possible, same object type is already bootstrapped.")
        } catch is DependencyContainer.RegisterError {
            // expected
        } catch let error {
            XCTFail("Unknown error: \(error)")
        }
    }
    
    func test_registerObjectAfterBootstrappedFails() throws {
        try sut.bootstrap()
        
        do {
            try sut.register { SingletonImpl1() }
            
            XCTFail("Shouldn't be possible, container is already bootstrapped.")
        } catch is DependencyContainer.RegisterError {
            // expected
        } catch let error {
            XCTFail("Unknown error: \(error)")
        }
    }
    
    func test_constructorInjectOtherDepency() throws {
        try sut.registerSingletonImpl1WithKey()
        
        try sut.register(TestKey.singleton2) {
            SingletonImpl2(other: try $0.resolveSingleton(.singleton1))
        }
    }
    
    func test_resolveUnknownObjectThrows() {
        do {
            let _: TestSingleton = try sut.resolve(using: .singleton1)
            
            XCTFail("Dependency shouldn't be registered!")
        } catch is DependencyContainer.ResolveError<TestSingleton> {
            // expected
        } catch let error {
            XCTFail("Unknown error: \(error)")
        }
    }
    
    func test_addSingletonForProtocol() throws {
        let singleton: SingletonImpl1 = SingletonImpl1()
        
        try sut.register(Singleton1.self) { singleton }
        
        try sut.register(Singleton2.self) {
            let singleton1: Singleton1 = try $0.resolve()
            return SingletonImpl2(other: singleton1)
        }
        
        let resolvedByProtocol: Singleton1 = try sut.resolve()
        
        XCTAssertTrue(resolvedByProtocol === singleton)
        
        let _: Singleton2 = try sut.resolve()
        
        do {
            let _: SingletonImpl2 = try sut.resolve()
            XCTFail("Dependency shouldn't be registered for it's class type!")
        } catch {
            // expected
        }
    }
    
    func test_addSingletonForClass() throws {
        let singleton: SingletonImpl1 = SingletonImpl1()
        
        try sut.register(BaseSingleton.self) { singleton }
        
        let resolvedByProvidedClass: BaseSingleton = try sut.resolve()
        
        XCTAssertTrue(resolvedByProvidedClass === singleton)
        
        do {
            let _: SingletonImpl1 = try sut.resolve()
            XCTFail("Dependency shouldn't be registered for it's class type!")
        } catch {
            // expected
        }
    }
    
    func test_addSingletonWithMultipleTypeInfo() throws {
        let singleton: SingletonImpl1 = SingletonImpl1()

        try sut.register([BaseSingleton.self, Singleton1.self]) { singleton }
        
        let resolved1: BaseSingleton = try sut.resolve()
        let resolved2: Singleton1 = try sut.resolve()
        
        XCTAssertTrue(resolved1 === singleton)
        XCTAssertTrue(resolved2 === singleton)
        
        do {
            let _: SingletonImpl1 = try sut.resolve()
            XCTFail("Dependency shouldn't be registered for it's class type!")
        } catch {
            // expected
        }
    }
    
    func test_multipleTypeInfoWithResolverContext() throws {
        try sut.register(TestSingleton.self) { SingletonImpl1() }
        
        try sut.register([Singleton2.self, SingletonImpl2.self]) {
            SingletonImpl2(other: try $0.resolve())
        }
        
        let _: TestSingleton = try sut.resolve()
        let resolved2_1: Singleton2 = try sut.resolve()
        let resolved2_2: SingletonImpl2 = try sut.resolve()
        
        XCTAssertTrue(resolved2_1 === resolved2_2)
        
        do {
            let _: Singleton1 = try sut.resolve()
            XCTFail("Dependency shouldn't be registered for that type information!")
        } catch let error {
            if case .notRegistered = error as? DependencyContainer.ResolveError<Singleton1> {
                // expected
            } else {
                XCTFail("Unknown error: \(error)")
            }
        }
    }
    
    func test_overrideRegisteredDependency() throws {
        var singleton1 = SingletonImpl1()
        try sut.register { singleton1 }
        
        try sut.register(TestSingleton.self) { SingletonImpl1() }
        
        try sut.bootstrap()
        
        try sut.override(TestSingleton.self) {
            let other: SingletonImpl1 = try $0.resolve()
            return SingletonImpl2(other: other)
        }
        
        let resolved: TestSingleton = try sut.resolve()
        XCTAssertTrue((resolved as? SingletonImpl2)?.other === singleton1)
        
        singleton1 = SingletonImpl1()
        try sut.override(TestSingleton.self) { singleton1 }
        
        XCTAssertTrue(singleton1 === (try sut.resolve(TestSingleton.self)))
    }
    
    @Singleton
    class AnnotatedClass {}
    
    protocol TestAbstraction {}
    protocol TestProtocol {}
    
    @Singleton(TestSingleton.self)
    class AnnotatedAbstractedClass: TestAbstraction {}
    
    @Singleton(TestSingleton.self, TestProtocol.self)
    class AnnotatedMultipleAbstractedClass: TestAbstraction {}
    
    func test_singletonMacro() throws {
//        _ = try AnnotatedClass.resolve()
    }
}

// MARK: - Helper

enum TestKey: CaseIterable {
    case singleton1
    case singleton2
}

extension DependencyContainer {
    
    func registerSingletonImpl1WithKey(id: String = "1", eager: Bool = false) throws {
        try register(TestKey.singleton1, isEager: eager) { SingletonImpl1(id: id) }
    }
    
    func registerSingletonImpl2WithKey(eager: Bool = false) throws {
        try register(TestKey.singleton2, isEager: eager) { SingletonImpl2(other: try $0.resolve(using: .singleton1)) }
    }
    
    func resolveSingleton(_ key: TestKey) throws -> TestSingleton {
        try resolve(using: key)
    }
    
    fileprivate func register<T>(for key: TestKey, element: @escaping () -> T) throws {
        try register(key, bootstrap: element)
    }
    
    fileprivate func resolve<T>(using key: TestKey) throws -> T {
        try resolve(key)
    }
}
