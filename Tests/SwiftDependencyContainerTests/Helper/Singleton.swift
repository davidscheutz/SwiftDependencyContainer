import Foundation

protocol Singleton: AnyObject {
    var id: String { get }
    var created: Date { get }
    var className: String { get }
}

class SingletonImpl1: BaseSigleton, Singleton {
    
    let created: Date = .init()
    let id: String
    
    init(id: String = "1") {
        self.id = id
    }
}

class SingletonImpl2: BaseSigleton, Singleton {
    
    let created: Date = .init()
    let id = "2"
    
    private let other: Singleton
    
    init(other: Singleton) {
        self.other = other
    }
}

class BaseSigleton {
    var className: String {
        String(describing: self)
    }
}
