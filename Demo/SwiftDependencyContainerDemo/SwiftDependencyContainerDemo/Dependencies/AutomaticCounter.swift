import Foundation
import SwiftDependencyContainer

@Factory
final class AutomaticCounter: ObservableObject, Identifiable {
    
    @Published private(set) var count = 0
    
    private let scheduler: Scheduler
    
    let id = UUID().uuidString
    
    // TODO: support default value
    init(timerInterval: TimeInterval = 1, tracking: CounterTracking) {
        scheduler = Scheduler(timerInterval: timerInterval)
        
        scheduler.start { [weak self] in
            DispatchQueue.main.async {
                self?.count += 1
            }
        }
        
        tracking.counterCreated()
    }
}
