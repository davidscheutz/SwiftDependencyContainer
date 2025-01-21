import Foundation

public final class DependencyContainer {

    public typealias BootstrapResolver<T> = (DependencyContainer) throws -> T
        
    public enum ResolveError<T>: Error {
        case notBootstrapped
        case noDependeciesRegistered
        case typeMismatch(actual: String)
        case notRegistered(key: String)
        case unknown(key: String, error: Error)
    }
    
    public enum OverrideError: Error {
        case notRegistered
    }
    
    public enum RegisterError: Error {
        case missingKey
        case aliasAlreadyTaken
        case alreadyBootstrapped(keys: String)
    }
    
    public static let `default` = DependencyContainer()
    
    public init() {}

    private var dependencies = [Key: AnyContainer]()
    private var eagerKeys = Set<Key>()
    private var keysAliases = [Key: Key]() // Alias: Source
    private var bootstrapped = false
    
    public func register<T, U>(alias: U.Type, for type: T.Type, override: Bool = false) throws {
        let aliasKey = keyValue(for: alias)
        
        let isKnwonAlias = keysAliases.keys.contains(aliasKey)
        
        guard !isKnwonAlias || override else {
            throw RegisterError.aliasAlreadyTaken
        }
        
        // resolve all aliases until root
        var sourceKey = keyValue(for: type)
        while let source = keysAliases[sourceKey] {
            sourceKey = source
        }
        
        register(alias: aliasKey, for: sourceKey)
    }
    
    public func register<T, U>(_ type: U.Type, isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try register(type, isEager: isEager) { _ in bootstrap() }
    }
    
    public func register<T>(_ types: [Any.Type], isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try register(types, isEager: isEager) { _ in bootstrap() }
    }
    
    public func register<T, U>(_ type: U.Type, isEager: Bool = false, bootstrap: @escaping BootstrapResolver<T>) throws {
        try register([type], isEager: isEager, bootstrap: bootstrap)
    }
    
    public func register<T>(_ types: [Any.Type], isEager: Bool = false, bootstrap: @escaping BootstrapResolver<T>) throws {
        let keys = types.map { keyValue(for: $0) }
        try register(Set(keys), isEager: isEager, bootstrap: bootstrap)
    }
    
    public func register<T>(isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try register(isEager: isEager) { _ in bootstrap() }
    }
    
    public func register<T>(isEager: Bool = false, bootstrap: @escaping BootstrapResolver<T>) throws {
        try register(T.self, isEager: isEager, bootstrap: bootstrap)
    }
    
    public func register<T>(_ key: AnyHashable, isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try register(key, isEager: isEager) { _ in bootstrap() }
    }
    
    public func register<T>(_ key: AnyHashable, isEager: Bool = false, bootstrap: @escaping BootstrapResolver<T>) throws {
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
    
    public func override<R, T>(_ replace: R.Type, _ resolve: @escaping BootstrapResolver<T>) throws {
        try override(key: keyValue(for: replace), resolve)
    }
    
    public func override<T>(_ key: AnyHashable, _ resolve: @escaping () -> T) throws {
        try override(key, { _ in resolve() })
    }
    
    public func override<T>(_ key: AnyHashable, _ resolve: @escaping BootstrapResolver<T>) throws {
        try override(key: keyValue(from: key), resolve)
    }
    
    // MARK: - Private
    
    private func register<T>(_ keys: Set<Key>, isEager: Bool = false, bootstrap: @escaping BootstrapResolver<T>) throws {
        guard !bootstrapped else {
            throw RegisterError.alreadyBootstrapped(keys: keys.map { $0.description }.joined(separator: ","))
        }
        
        guard !keys.isEmpty else {
            throw RegisterError.missingKey
        }
        
        let dependency = AnyContainer(resolver: bootstrap)
        
        var keysToRegister = keys
        
        let sourceKey = keysToRegister.removeFirst()
        dependencies[sourceKey] = dependency
        
        // remaining keys will reference the same dependency as alias
        keysToRegister.forEach { register(alias: $0, for: sourceKey) }
        
        if isEager {
            eagerKeys.insert(sourceKey)
        } else {
            eagerKeys.remove(sourceKey)
        }
    }
    
    private func register(alias aliasKey: Key, for sourceKey: Key) {
        keysAliases[aliasKey] = sourceKey
    }
    
    private func resolve<T>(using key: Key) throws -> T {
        if !bootstrapped && eagerKeys.isEmpty {
            // automatically bootsrap if there are no eager dependencies
            bootstrapped = true
        }
        
        guard bootstrapped else {
            throw ResolveError<T>.notBootstrapped
        }
        
        if dependencies.isEmpty {
            throw ResolveError<T>.noDependeciesRegistered
        }
        
        let allKeys = [key] + (keysAliases[key].map { [$0] } ?? [])
        
        guard let container = allKeys.lazy.compactMap({ self.dependencies[$0] }).first else {
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
    
    private func override<T>(key: Key, _ override: @escaping BootstrapResolver<T>) throws {
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
