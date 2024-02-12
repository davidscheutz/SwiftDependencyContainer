import Foundation

extension DependencyContainer {
    
    // TODO: evaluate ObjectIdentifier as an option, would that work with named keys as well?
    // https://developer.apple.com/documentation/swift/objectidentifier
    
    internal struct Key: Hashable {
        let raw: String
        let hashed: Int
                
        init(key: AnyHashable) {
            raw = "\(key)"
            hashed = key.hashValue
        }
        
        var description: String {
            "Raw: \(raw) - Hash: \(hashed)"
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(hashed)
        }
    }
}
