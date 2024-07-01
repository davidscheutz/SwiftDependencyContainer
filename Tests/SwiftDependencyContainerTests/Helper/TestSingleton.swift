import Foundation

protocol TestSingleton: AnyObject {
    var id: String { get }
    var created: Date { get }
    var className: String { get }
}

protocol Singleton1: TestSingleton {}
protocol Singleton2: TestSingleton {}

final class SingletonImpl1: BaseSingleton, Singleton1 {
    
    let created: Date = .init()
    let id: String
    
    init(id: String = "1") {
        self.id = id
    }
}

final class SingletonImpl2: BaseSingleton, Singleton2 {
    
    let created: Date = .init()
    let id = "2"
    let other: TestSingleton
    
    init(other: TestSingleton) {
        self.other = other
    }
}

class BaseSingleton {
    var className: String {
        String(describing: self)
    }
}
