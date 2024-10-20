
import SwiftUI

@main
struct PEMFApp: App {
    @State private var toneGenerator = ToneGenerator()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(toneGenerator)
        }
    }
}
