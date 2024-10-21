
import SwiftUI
import SwiftData

@main
struct PEMFApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var toneGenerator = ToneGenerator()
    @State private var volumeObserver = VolumeObserver()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(toneGenerator)
                .environment(volumeObserver)
        }
        .modelContainer(for: TherapySession.self)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
