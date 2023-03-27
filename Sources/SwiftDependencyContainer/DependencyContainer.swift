import Foundation

public struct DependencyContainer {

    public typealias Resolver<T> = (Self.Type) throws -> T
    
    private typealias Key = String
    private typealias AnyResolver = Resolver<Any>
    
    public struct ResolveError: Error {
        public let key: String
        public let classDescription: String
    }
    
    enum RegisterError: Error {
        case alreadyRegistered(key: String)
    }
    
    private static var bootstraps = [Key: AnyResolver]()
    private static var dependencies = [Key: Any]()
    
    public static func add<Key: Hashable, T>(_ key: Key, isEager: Bool = false, bootstrap: @escaping () -> T) throws {
        try add(key, isEager: isEager, bootstrap: { _ in bootstrap() })
    }
    
    public static func add<Key: Hashable, T>(_ key: Key, isEager: Bool = false, bootstrap: @escaping Resolver<T>) throws {
        let key = keyValue(from: key)
        
        let allKeys = Set(dependencies.keys).union(bootstraps.keys)
        guard !allKeys.contains(key) else {
            throw RegisterError.alreadyRegistered(key: key)
        }
        
        if isEager {
            dependencies[key] = try bootstrap(self)
        } else {
            bootstraps[key] = bootstrap
        }
    }
    
    public static func resolve<Key: Hashable, T>(_ key: Key) throws -> T {
        let key = keyValue(for: key)
        
        if let dependency = dependencies[key] as? T {
            return dependency
        }
        
        if let bootstrap = bootstraps.removeValue(forKey: key),
            let dependency = try bootstrap(self) as? T {
            dependencies[key] = dependency
            return dependency
        }
        
        throw ResolveError(key: key, classDescription: String(describing: T.self))
    }
    
    @discardableResult
    public static func remove<Key: Hashable>(_ key: Key) -> Bool {
        let key = keyValue(for: key)
        
        return dependencies.removeValue(forKey: key) != nil || bootstraps.removeValue(forKey: key) != nil
    }
    
    // MARK: - Helper
    
    private static func keyValue<Key: Hashable>(for key: Key) -> Self.Key {
        String(key.hashValue)
    }
}
