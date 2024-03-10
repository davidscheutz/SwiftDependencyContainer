import Foundation
import SwiftDependencyContainer

struct Dependencies: AutoSetup {
    let container = DependencyContainer()
    
    func override(_ container: DependencyContainer) throws {
        #if DEBUG
        try container.register(AnalyticsTracker.self) { AnalyticsTrackerMock() }
        #else
        try container.register(AnalyticsTracker.self) { AnalyticsTrackerImpl() }
        #endif
    }
}
