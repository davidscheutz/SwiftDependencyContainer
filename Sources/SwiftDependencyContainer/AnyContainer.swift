import Foundation

internal final class AnyContainer {
    
    typealias AnyResolver = DependencyContainer.BootstrapResolver<Any>
    
    private let resolver: AnyResolver
    // TODO: would be cool to use lazy with completion as constructor
    // TODO: make Any sendable // https://developer.apple.com/documentation/swift/sendable
    private var value: Any?
    
    init(resolver: @escaping AnyResolver) {
        self.resolver = resolver
    }
    
    var isResolved: Bool {
        value != nil
    }
    
    func resolve(_ container: DependencyContainer) throws -> Any {
        if !isResolved {
            value = try resolver(container)
        }
        return value! // safe to force unwrap here
    }
}
