
import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int = 0
    @State private var timerManager = TimerManager()
    
    @Environment(VolumeObserver.self) private var volumeObserver
    @State private var showVolumeAlert: Bool = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CustomGeneratorView()
                .tabItem {
                    Label("Custom", systemImage: "slider.horizontal.3")
                }
                .tag(0)
                .overlay {
                    if showVolumeAlert {
                        VolumeAlertView(isPresented: $showVolumeAlert)
                    }
                }
            
            PresetFrequenciesView()
                .tabItem {
                    Label("Presets", systemImage: "list.bullet")
                }
                .tag(1)
                .overlay {
                    if showVolumeAlert {
                        VolumeAlertView(isPresented: $showVolumeAlert)
                    }
                }
            
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
        .onChange(of: volumeObserver.volume) { _, _ in
            checkVolume()
        }
        .onAppear {
            checkVolume()
        }
    }
    
    private func checkVolume() {
        if volumeObserver.volume < 0.75 {
            showVolumeAlert = true
        }
    }
}

#Preview {
    MainView()
        .environment(ToneGenerator())
        .environment(VolumeObserver())
}
