import Foundation

public protocol DependencyKey: Hashable {
    typealias Value = String
    
    var value: Value { get }
}

// TODO: use class name as key

public struct DependencyContainer {
    
    public struct ResolveError: Error {
        public let key: String
        public let classDescription: String
    }
    
    private static var bootstraps = [DependencyKey.Value: (Self.Type) -> Any]()
    private static var dependencies = [DependencyKey.Value: Any]()
    
//    public static func add<T>(isEager: Bool = false, bootstrap: @escaping () -> T) {
//        let key = ""
//        add(key, isEager: isEager, bootstrap: { _ in bootstrap() })
//    }
    
    public static func add<Key: DependencyKey, T>(_ key: Key, isEager: Bool = false, bootstrap: @escaping () -> T) {
        add(key, isEager: isEager, bootstrap: { _ in bootstrap() })
    }
    
    public static func add<Key: DependencyKey, T>(_ key: Key, isEager: Bool = false, bootstrap: @escaping (Self.Type) -> T) {
        // If dependency for key already exists, replace it directly
        if isEager || dependencies.keys.contains(key.value) {
            dependencies[key.value] = bootstrap(self)
        } else {
            bootstraps[key.value] = bootstrap
        }
    }
    
    public static func resolve<Key: DependencyKey, T>(_ key: Key) throws -> T {
        if let dependency = dependencies[key.value] as? T {
            return dependency
        }
        
        if let bootstrap = bootstraps.removeValue(forKey: key.value),
            let dependency = bootstrap(self) as? T {
            dependencies[key.value] = dependency
            return dependency
        }
        
        throw ResolveError(key: key.value, classDescription: String(describing: T.self))
    }
    
    @discardableResult
    public static func remove<Key: DependencyKey>(_ key: Key) -> Bool {
        let key = key.value
        return dependencies.removeValue(forKey: key) != nil || bootstraps.removeValue(forKey: key) != nil
    }
}
