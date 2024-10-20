
import SwiftUI
import SwiftData

@main
struct PEMFApp: App {
    @State private var toneGenerator = ToneGenerator()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(toneGenerator)
        }
        .modelContainer(for: TherapySession.self)
    }
}
