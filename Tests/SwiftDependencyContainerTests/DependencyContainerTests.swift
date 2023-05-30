import XCTest
import SwiftDependencyContainer

class DependencyContainerTests: XCTestCase {
    
    let sut = DependencyContainer.self
        
    override func setUp() {
        TestKey.allCases.forEach {
            sut.remove($0)
        }
    }
    
    func test_bootstrapOnDemand() throws {
        try sut.registerSingletonImpl1WithKey()
        
        let start = Date()
        
        let singleton = try sut.resolveSingleton(.singleton1)
        
        XCTAssertTrue(start < singleton.created)
    }
    
    func test_eagerBootstrap() throws {
        try sut.registerSingletonImpl1WithKey(eager: true)
        
        let start = Date()
        
        let singleton = try sut.resolveSingleton(.singleton1)
        
        XCTAssertTrue(start > singleton.created)
    }
    
    func test_singleInstance() throws {
        try sut.registerSingletonImpl1WithKey()
        
        XCTAssertTrue(try sut.resolveSingleton(.singleton1) === sut.resolveSingleton(.singleton1))
    }
    
    func test_replaceRegisteredInstanceBeforeBootsrap() throws {
        try sut.registerSingletonImpl1WithKey(id: "1")
        try sut.registerSingletonImpl1WithKey(id: "2")
        
        let result = try sut.resolveSingleton(.singleton1)
        XCTAssertEqual(result.id, "2")
    }
    
    func test_registerAfterEagerRegisterFails() throws {
        try sut.registerSingletonImpl1WithKey(eager: true)
        
        do {
            try sut.registerSingletonImpl1WithKey()
            XCTFail("Should fail, dependency for key is already bootstrapped.")
        } catch {}
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
        try sut.add(isEager: true) { SingletonImpl1() }
        
        try sut.add {
            let s1: SingletonImpl1 = try $0.resolve()
            return SingletonImpl2(other: s1)
        }
        
        let _: SingletonImpl1 = try sut.resolve()
        let _: SingletonImpl2 = try sut.resolve()
        
        let resolvedFailure: Singleton? = try? sut.resolve()
        XCTAssertNil(resolvedFailure)
    }
    
    func test_constructorInjectOtherDepency() throws {
        try sut.registerSingletonImpl1WithKey()
        
        try sut.add(TestKey.singleton2) {
            SingletonImpl2(other: try $0.resolveSingleton(.singleton1))
        }
    }
    
    func test_resolveUnknownObjectThrows() {
        do {
            let _: Singleton = try sut.resolve(using: .singleton1)
            
            XCTFail("Dependency shouldn't be registered!")
        } catch is DependencyContainer.ResolveError {
            // expected
        } catch let error {
            XCTFail("Unknown error: \(error)")
        }
    }
    
    func test_removeRegisteredDepency() throws {
        try sut.registerSingletonImpl1WithKey(eager: true)
        try sut.registerSingletonImpl2WithKey()
        
        sut.remove(TestKey.singleton1)
        sut.remove(TestKey.singleton2)
                
        XCTAssertNil(try? sut.resolveSingleton(.singleton1))
        XCTAssertNil(try? sut.resolveSingleton(.singleton2))
    }
}

// MARK: - Helper

enum TestKey: String, CaseIterable {
    case singleton1
    case singleton2
}

extension DependencyContainer {
    
    static func registerSingletonImpl1WithKey(id: String = "1", eager: Bool = false) throws {
        try add(TestKey.singleton1, isEager: eager) { SingletonImpl1(id: id) }
    }
    
    static func registerSingletonImpl2WithKey(eager: Bool = false) throws {
        try add(TestKey.singleton2, isEager: eager) { SingletonImpl2(other: try $0.resolve(using: .singleton1)) }
    }
    
    static func resolveSingleton(_ key: TestKey) throws -> Singleton {
        try resolve(using: key)
    }
    
    fileprivate static func add<T>(for key: TestKey, element: @escaping () -> T) throws {
        try add(key, bootstrap: element)
    }
    
    fileprivate static func resolve<T>(using key: TestKey) throws -> T {
        try resolve(key)
    }
}
