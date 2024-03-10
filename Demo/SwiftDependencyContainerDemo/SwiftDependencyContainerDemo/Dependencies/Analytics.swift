import Foundation

protocol ClockTracking {
    func clockStarted()
}

protocol CounterTracking {
    func counterCreated()
}

protocol Tracking: ClockTracking, CounterTracking {}

/// @Singleton(types: [ClockTracking, CounterTracking])
final class Analytics: Tracking {
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
