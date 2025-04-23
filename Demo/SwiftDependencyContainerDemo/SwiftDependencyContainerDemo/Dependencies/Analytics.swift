import Foundation
import SwiftDependencyContainer

protocol ClockTracking {
    func clockStarted()
}

@Alias(for: Analytics.self)
protocol CounterTracking {
    func counterCreated()
}

@Singleton(ClockTracking.self)
final class Analytics: ClockTracking, CounterTracking {
    init(tracker: AnalyticsTracker) {}
    
    func clockStarted() {
//        tracker.report("clock_started")
    }
    
    func counterCreated() {
//        tracker.report("counter_created")
    }
}

protocol AnalyticsTracker {}

final class AnalyticsTrackerMock: AnalyticsTracker {}

final class AnalyticsTrackerImpl: AnalyticsTracker {}
