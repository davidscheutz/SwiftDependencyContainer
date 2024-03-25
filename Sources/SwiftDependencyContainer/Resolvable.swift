import Foundation

public protocol Resolvable {
    func resolve<T>() -> T
}
