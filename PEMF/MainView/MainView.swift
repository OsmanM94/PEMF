
import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CustomGeneratorView()
                .tabItem {
                    Label("Custom", systemImage: "slider.horizontal.3")
                }
                .tag(0)
            
            PresetFrequenciesView()
                .tabItem {
                    Label("Presets", systemImage: "list.bullet")
                }
                .tag(1)
            
            TimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
                .tag(2)
            
            SessionTrackerView()
                .tabItem {
                    Label("Sessions", systemImage: "calendar")
                }
                .tag(3)
        }
    }
}

#Preview {
    MainView()
        .environment(ToneGenerator())
}
