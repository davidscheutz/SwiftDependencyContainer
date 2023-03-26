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
        try sut.registerSingletonImpl1()
        
        let start = Date()
        
        let singleton = sut.resolveSingleton(.singleton1)
        
        XCTAssertTrue(start < singleton.created)
    }
    
    func test_eagerBootstrap() throws {
        try sut.registerSingletonImpl1Eager()
        
        let start = Date()
        
        let singleton = sut.resolveSingleton(.singleton1)
        
        XCTAssertTrue(start > singleton.created)
    }
    
    func test_singleInstance() throws {
        try sut.registerSingletonImpl1()
        
        XCTAssertTrue(sut.resolveSingleton(.singleton1) === sut.resolveSingleton(.singleton1))
        XCTAssertTrue(sut.resolveSingletonImpl1() === sut.resolveSingleton(.singleton1))
        XCTAssertTrue(sut.resolveSingletonImpl1() === sut.resolveSingletonImpl1())
    }
    
    func test_registerAfterBootstrapedsFails() throws {
        try sut.registerSingletonImpl1Eager()
        
        do {
            try sut.registerSingletonImpl1()
            XCTFail("Should fail, dependency for key is already registered.")
        } catch {}
    }
    
    func test_registerSameKeyTwiceFails() throws {
        try sut.registerSingletonImpl1()
        
        do {
            try sut.registerSingletonImpl1()
            XCTFail("Should fail, dependency for key is already registered eager.")
        } catch {}
    }
    
    func test_constructorInjectOtherDepency() throws {
        try sut.registerSingletonImpl2()
        
        try sut.add(TestKey.singleton1) {
            SingletonImpl2(other: $0.resolveSingleton(.singleton2))
        }
    }
    
    func test_resolveUnknownClassThrows() {
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
        try sut.registerSingletonImpl1Eager()
        try sut.registerSingletonImpl2()
        
        sut.remove(TestKey.singleton1)
        sut.remove(TestKey.singleton2)
        
        XCTAssertNil(try? sut.resolve(using: .singleton1))
        XCTAssertNil(try? sut.resolve(using: .singleton2))
    }
}

// MARK: - Helper

enum TestKey: String, CaseIterable {
    case singleton1
    case singleton2
}

extension DependencyContainer {
    
    static func registerSingletonImpl1() throws {
        try add(TestKey.singleton1) { SingletonImpl1() }
    }
    
    static func registerSingletonImpl2() throws {
        try add(TestKey.singleton2) { SingletonImpl2(other: resolveSingletonImpl1()) }
    }
    
    static func registerSingletonImpl1Eager() throws {
        try add(TestKey.singleton1, isEager: true) { SingletonImpl1() }
    }
    
    static func resolveSingleton(_ key: TestKey) -> Singleton {
        try! resolve(using: key)
    }
    
    static func resolveSingletonImpl1() -> SingletonImpl1 {
        try! resolve(using: .singleton1)
    }
    
    static func resolveSingletonImpl2() -> SingletonImpl2 {
        try! resolve(using: .singleton2)
    }
    
    fileprivate static func add<T>(for key: TestKey, element: @escaping () -> T) throws {
        try add(key, bootstrap: element)
    }
    
    fileprivate static func resolve<T>(using key: TestKey) throws -> T {
        try resolve(key)
    }
}
