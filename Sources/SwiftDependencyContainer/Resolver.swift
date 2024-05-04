import Foundation

public protocol Resolver {
    func resolve<T>() -> T
}

internal struct DependencyResolver: Resolver {
    let container: DependencyContainer
    
    func resolve<T>() -> T {
        try! container.resolve()
    }
}

extension DependencyContainer {
    public func resolver() -> Resolver {
        DependencyResolver(container: self)
    }
}
