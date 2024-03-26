import Foundation

public protocol Resolvable {
    func resolve<T>() -> T
}

internal struct DependencyResolver: Resolvable {
    let container: DependencyContainer
    
    func resolve<T>() -> T {
        try! container.resolve()
    }
}

extension DependencyContainer {
    public func resolver() -> Resolvable {
        DependencyResolver(container: self)
    }
}
