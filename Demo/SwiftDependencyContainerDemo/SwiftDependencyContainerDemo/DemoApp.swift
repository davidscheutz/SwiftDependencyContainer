import SwiftUI

@main
struct DemoApp: App {
    
    init() {
        Dependencies.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
