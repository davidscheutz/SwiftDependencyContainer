import Foundation

public protocol AutoSetup: Resolver {
    var container: DependencyContainer { get }
    
    func override(_ container: DependencyContainer) throws
}

extension AutoSetup {
    public func override(_ container: DependencyContainer) throws {}
}
