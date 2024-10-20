
import SwiftUI

struct MainView: View {
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView {
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
        }
    }
}

#Preview {
    MainView()
        .environment(ToneGenerator())
}
