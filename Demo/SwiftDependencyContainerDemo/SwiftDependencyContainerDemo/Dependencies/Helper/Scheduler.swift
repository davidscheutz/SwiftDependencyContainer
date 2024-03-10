import Foundation

final class Scheduler {
    
    private let timerInterval: TimeInterval
    
    private var timer: Timer?

    init(timerInterval: TimeInterval) {
        self.timerInterval = timerInterval
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func start(_ perform: @escaping () -> Void) {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            perform()
        }
    }
}
