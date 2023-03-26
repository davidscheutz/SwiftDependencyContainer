import XCTest
import SwiftDependencyContainer

class DependencyContainerTests: XCTestCase {
    
    let sut = DependencyContainer.self
    
    typealias Key = DependencyContainer.Key
    
    override func setUp() {
        Key.allCases.forEach {
            sut.remove($0)
        }
    }
    
    func test_bootstrapOnDemand() {
        sut.registerSingletonImpl1()
        
        let start = Date()
        
        let singleton = sut.resolveSingleton(.singleton1)
        
        XCTAssertTrue(start < singleton.created)
    }
    
    func test_eagerBootstrap() {
        sut.registerEagerSingleton()
        
        let start = Date()
        
        let singleton = sut.resolveSingleton(.singleton1)
        
        XCTAssertTrue(start > singleton.created)
    }
    
    func test_singleInstance() throws {
        sut.registerSingletonImpl1()
        
        XCTAssertTrue(sut.resolveSingleton(.singleton1) === sut.resolveSingleton(.singleton1))
        XCTAssertTrue(sut.resolveSingletonImpl1() === sut.resolveSingleton(.singleton1))
        XCTAssertTrue(sut.resolveSingletonImpl1() === sut.resolveSingletonImpl1())
    }
    
    func test_replaceInstanceForSameKey() {
        sut.registerSingletonImpl1()
        
        let singletonV1 = sut.resolveSingletonImpl1()
        
        sut.registerSingletonImpl1()
        
        let singletonV2 = sut.resolveSingletonImpl1()
        
        XCTAssertNotEqual(singletonV1.created, singletonV2.created)
        XCTAssertFalse(singletonV1 === singletonV2)
    }
    
    func test_constructorInjectOtherDepency() {
        sut.registerSingletonImpl2()
        
        sut.add(Key.singleton1) {
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
    
    func test_removeRegisteredDepency() {
        sut.registerEagerSingleton()
        sut.registerSingletonImpl2()
        
        sut.remove(Key.singleton1)
        sut.remove(Key.singleton2)
        
        XCTAssertNil(try? sut.resolve(using: .singleton1))
        XCTAssertNil(try? sut.resolve(using: .singleton2))
    }
}

// MARK: - Helper

extension DependencyContainer {
    
    enum Key: String, CaseIterable, DependencyKey {
        case singleton1
        case singleton2
        
        var value: Value { rawValue }
    }
    
    static func registerSingletonImpl1() {
        add(Key.singleton1) { SingletonImpl1() }
    }
    
    static func registerSingletonImpl2() {
        add(Key.singleton2) { SingletonImpl2(other: resolveSingletonImpl1()) }
    }
    
    static func registerEagerSingleton() {
        add(Key.singleton1, isEager: true) { SingletonImpl1() }
    }
    
    static func resolveSingleton(_ key: Key) -> Singleton {
        try! resolve(using: key)
    }
    
    static func resolveSingletonImpl1() -> SingletonImpl1 {
        try! resolve(using: .singleton1)
    }
    
    static func resolveSingletonImpl2() -> SingletonImpl2 {
        try! resolve(using: .singleton2)
    }
    
    fileprivate static func add<T>(for key: Key, element: @escaping () -> T) {
        add(key, bootstrap: element)
    }
    
    fileprivate static func resolve<T>(using key: Key) throws -> T {
        try resolve(key)
    }
}
