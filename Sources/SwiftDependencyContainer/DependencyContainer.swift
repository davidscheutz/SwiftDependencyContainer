import Foundation

public final class DependencyContainer {

    public typealias Resolver<T> = (DependencyContainer) throws -> T
        
    public enum ResolveError<T>: Error {
        case notBootstrapped
        case typeMismatch(actual: String)
        case notRegistered
        case unknown(key: String, error: Error)
    }
    
    public enum RegisterError: Error {
        case alreadyBootstrapped(keys: String)
    }
    
    public static let `default` = DependencyContainer()
    
    public init() {}

    private var dependencies = [Key: AnyContainer]()
    private var eagerKeys = Set<Key>()
    private var bootstrapped = false
    
    public func add<T, U>(for type: U.Type, isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try add(for: type, isEager: isEager) { _ in bootstrap() }
    }
    
    public func add<T>(for types: [Any.Type], isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try add(for: types, isEager: isEager) { _ in bootstrap() }
    }
    
    public func add<T, U>(for type: U.Type, isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        try add(for: [type], isEager: isEager, bootstrap: bootstrap)
    }
    
    public func add<T>(for types: [Any.Type], isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        let keys = types.map { keyValue(for: $0) }
        try register(Set(keys), isEager: isEager, bootstrap: bootstrap)
    }
    
    public func add<T>(isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try add(isEager: isEager) { _ in bootstrap() }
    }
    
    public func add<T>(isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        try add(for: T.self, isEager: isEager, bootstrap: bootstrap)
    }
    
    public func add<T>(_ key: AnyHashable, isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try add(key, isEager: isEager) { _ in bootstrap() }
    }
    
    public func add<T>(_ key: AnyHashable, isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        try register([keyValue(from: key)], isEager: isEager, bootstrap: bootstrap)
    }
    
    public func resolve<T>() throws -> T {
        try resolve(using: keyValue(for: T.self))
    }
    
    public func resolve<T>(_ key: AnyHashable) throws -> T {
        try resolve(using: keyValue(from: key))
    }

    public func bootstrap() throws {
        try dependencies.forEach {
            if eagerKeys.contains($0.key) {
                _ = try $0.value.resolve(self)
            }
        }
        
        bootstrapped = true
    }
    
    // MARK: - Private
    
    private func register<T>(_ keys: Set<Key>, isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        guard !bootstrapped else {
            throw RegisterError.alreadyBootstrapped(keys: keys.map { $0.description }.joined(separator: ","))
        }
        
        guard !keys.isEmpty else {
            return
        }
        
        let dependency = AnyContainer(resolver: bootstrap)
        
        // multiple keys can reference the same dependency
        keys.forEach { dependencies[$0] = dependency }
        
        let eagerKey = keys.first!
        if isEager {
            eagerKeys.insert(eagerKey)
        } else {
            eagerKeys.remove(eagerKey)
        }
    }
    
    private func resolve<T>(using key: Key) throws -> T {
        if !bootstrapped && eagerKeys.isEmpty {
            // automatically bootsrap if there are no eager dependencies
            bootstrapped = true
        }
        
        guard bootstrapped else {
            throw ResolveError<T>.notBootstrapped
        }
        
        guard let container = dependencies[key] else {
            throw ResolveError<T>.notRegistered
            //.create(key: key, type: T.self, reason: "Dependency not registered!")
        }
        
        do {
            let resolved = try container.resolve(self)
            
            guard let dependency = resolved as? T else {
                throw ResolveError<T>.typeMismatch(actual: "\(type(of: resolved))")
            }
            
            return dependency
        } catch let error {
            throw ResolveError<T>.unknown(key: key.raw, error: error)
        }
    }
    
    // MARK: - Helper
    
    private func keyValue(for objectType: Any.Type) -> Key {
        keyValue(from: String(describing: objectType))
    }
    
    private func keyValue(from key: AnyHashable) -> Key {
        .init(key: key)
    }
}
