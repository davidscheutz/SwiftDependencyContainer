import Foundation

public final class DependencyContainer {

    public typealias Resolver<T> = (DependencyContainer) throws -> T
        
    public struct ResolveError: Error {
        public let key: String
        public let classDescription: String
    }
    
    enum RegisterError: Error {
        case alreadyBootstrapped(keys: String)
    }
    
    public static let `default` = DependencyContainer()
    
    public init() {}

    private var dependencies = [Key: AnyContainer]()
    
    public func add<T, U>(for type: U.Type, isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try add(for: type, isEager: isEager) { _ in bootstrap() }
    }
    
    public func add<T>(for types: [Any.Type], isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try add(for: types, isEager: isEager) { _ in bootstrap() }
    }
    
    public func add<T, U>(for type: U.Type, isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        try add(for: [T.self, U.self], isEager: isEager, bootstrap: bootstrap)
    }
    
    public func add<T>(for types: [Any.Type], isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        let keys = (types + [T.self]).map { keyValue(for: $0) }
        try register(Set(keys), isEager: isEager, bootstrap: bootstrap)
    }
    
    public func add<T>(isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try add(isEager: isEager) { _ in bootstrap() }
    }
    
    public func add<T>(isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        try register([keyValue(for: T.self)], isEager: isEager, bootstrap: bootstrap)
    }
    
    public func add<Key: Hashable, T>(_ key: Key, isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try add(key, isEager: isEager, bootstrap: { _ in bootstrap() })
    }
    
    public func add<Key: Hashable, T>(_ key: Key, isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        try register([keyValue(from: key)], isEager: isEager, bootstrap: bootstrap)
    }
    
    public func resolve<T>() throws -> T {
        try resolve(using: keyValue(for: T.self))
    }
    
    public func resolve<Key: Hashable, T>(_ key: Key) throws -> T {
        try resolve(using: keyValue(from: key))
    }

    // MARK: - Private
    
    private func register<T>(_ keys: Set<Key>, isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        let newKeys = Set(keys).subtracting(dependencies.keys)
        let alreadyRegisteredKeys = keys.subtracting(newKeys).filter { dependencies[$0]?.isResolved == true }
        
        guard alreadyRegisteredKeys.isEmpty else {
            throw RegisterError.alreadyBootstrapped(keys: alreadyRegisteredKeys.map { $0.description }.joined(separator: ","))
        }
        
        let dependency = AnyContainer(resolver: bootstrap)
        
        keys.forEach { dependencies[$0] = dependency }
        
        if isEager {
            _ = try dependency.resolve(self)
        }
    }
    
    private func resolve<T>(using key: Key) throws -> T {
        guard let dependency = try dependencies[key]?.resolve(self) as? T else {
            throw ResolveError(key: key.description, classDescription: String(describing: T.self))
        }
        
        return dependency
    }
    
    // MARK: - Helper
    
    private func keyValue(for objectType: Any.Type) -> Key {
        keyValue(from: String(describing: objectType))
    }
    
    private func keyValue<Key: Hashable>(from key: Key) -> DependencyContainer.Key {
        .init(raw: "\(key)", hashed: key.hashValue)
    }
}
