import Foundation

public final class DependencyContainer {

    public typealias Resolver<T> = (DependencyContainer) throws -> T
        
    public enum ResolveError<T>: Error {
        case notBootstrapped
        case typeMismatch(actual: String)
        case notRegistered(key: String)
        case unknown(key: String, error: Error)
    }
    
    public enum OverrideError: Error {
        case notRegistered
    }
    
    public enum RegisterError: Error {
        case missingKey
        case alreadyBootstrapped(keys: String)
    }
    
    public static let `default` = DependencyContainer()
    
    public init() {}

    private var dependencies = [Key: AnyContainer]()
    private var eagerKeys = Set<Key>()
    private var bootstrapped = false
    
    public func register<T, U>(_ type: U.Type, isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try register(type, isEager: isEager) { _ in bootstrap() }
    }
    
    public func register<T>(_ types: [Any.Type], isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try register(types, isEager: isEager) { _ in bootstrap() }
    }
    
    public func register<T, U>(_ type: U.Type, isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        try register([type], isEager: isEager, bootstrap: bootstrap)
    }
    
    public func register<T>(_ types: [Any.Type], isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        let keys = types.map { keyValue(for: $0) }
        try register(Set(keys), isEager: isEager, bootstrap: bootstrap)
    }
    
    public func register<T>(isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try register(isEager: isEager) { _ in bootstrap() }
    }
    
    public func register<T>(isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        try register(T.self, isEager: isEager, bootstrap: bootstrap)
    }
    
    public func register<T>(_ key: AnyHashable, isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try register(key, isEager: isEager) { _ in bootstrap() }
    }
    
    public func register<T>(_ key: AnyHashable, isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        try register([keyValue(from: key)], isEager: isEager, bootstrap: bootstrap)
    }
    
    public func resolve<T>() throws -> T {
        try resolve(using: keyValue(for: T.self))
    }
    
    public func resolve<T>(_ type: T.Type) throws -> T {
        try resolve(using: keyValue(for: type))
    }
    
    public func resolve<T>(_ key: AnyHashable) throws -> T {
        try resolve(using: keyValue(from: key))
    }

    public func bootstrap() throws {
        bootstrapped = true
        
        try dependencies.forEach {
            if eagerKeys.contains($0.key) {
                _ = try $0.value.resolve(self)
            }
        }
    }
    
    public func override<R, T>(_ replace: R.Type, _ resolve: @escaping () -> T) throws {
        try override(replace, { _ in resolve() })
    }
    
    public func override<R, T>(_ replace: R.Type, _ resolve: @escaping Resolver<T>) throws {
        try override(key: keyValue(for: replace), resolve)
    }
    
    public func override<T>(_ key: AnyHashable, _ resolve: @escaping () -> T) throws {
        try override(key, { _ in resolve() })
    }
    
    public func override<T>(_ key: AnyHashable, _ resolve: @escaping Resolver<T>) throws {
        try override(key: keyValue(from: key), resolve)
    }
    
    // MARK: - Private
    
    private func register<T>(_ keys: Set<Key>, isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        guard !bootstrapped else {
            throw RegisterError.alreadyBootstrapped(keys: keys.map { $0.description }.joined(separator: ","))
        }
        
        guard !keys.isEmpty else {
            throw RegisterError.missingKey
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
            throw ResolveError<T>.notRegistered(key: key.description)
        }
        
        let resolved: Any
        
        do {
            resolved = try container.resolve(self)
        } catch let error {
            throw ResolveError<T>.unknown(key: key.raw, error: error)
        }
        
        guard let dependency = resolved as? T else {
            throw ResolveError<T>.typeMismatch(actual: "\(type(of: resolved))")
        }
        
        return dependency
    }
    
    private func override<T>(key: Key, _ override: @escaping Resolver<T>) throws {
        guard dependencies.keys.contains(key) else {
            throw OverrideError.notRegistered
        }
        dependencies[key] = AnyContainer(resolver: override)
    }
    
    // MARK: - Helper
    
    private func keyValue(for objectType: Any.Type) -> Key {
        keyValue(from: String(describing: objectType))
    }
    
    private func keyValue(from key: AnyHashable) -> Key {
        .init(key: key)
    }
}
