import Foundation

protocol Singleton: AnyObject {
    var created: Date { get }
    var className: String { get }
}

class SingletonImpl1: Singleton {
    
    let created: Date = .init()
    
    var className: String {
        String(describing: self)
    }
}

class SingletonImpl2: Singleton {
    
    let created: Date = .init()
    
    private let other: Singleton
    
    init(other: Singleton) {
        self.other = other
    }
    
    var className: String {
        String(describing: self)
    }
}
