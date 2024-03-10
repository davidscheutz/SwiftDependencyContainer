import Foundation
import Combine

/// @EagerSingleton
final class Clock: ObservableObject {
    @Published private(set) var formattedTime = ""
    
    private var timer: Timer?

    private let scheduler = Scheduler(timerInterval: 0.02)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()
    
    init(tracking: ClockTracking) {
        scheduler.start(updateTime)
        tracking.clockStarted()
    }
    
    private func updateTime() {
        DispatchQueue.main.async {
            self.formattedTime = self.dateFormatter.string(from: .now)
        }
    }
}
