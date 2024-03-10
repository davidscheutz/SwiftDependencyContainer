import SwiftUI

struct ContentView: View {
    
    // Dependencies root access
    @StateObject private var clock = Dependencies.clock
    
    // Direct access
//    @StateObject var clock = Clock.resolve()
    
    @State var counters = [AutomaticCounter]()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Text(clock.formattedTime)
            
            Button("Add Counter") {
                counters.append(AutomaticCounter.create(timerInterval: 1))
            }
            
            ForEach(counters) {
                Text("Count: \($0.count)")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
