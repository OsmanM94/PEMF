
import SwiftUI


struct PresetFrequenciesView: View {
    @Environment(ToneGenerator.self) private var toneGenerator
    @State private var activePresets: [String: PresetTimer] = [:]
    
    let presets: [Preset] = [
        Preset(name: "Relaxation", frequency1: 10.0, dutyCycle1: 0.5, frequency2: 7.83, dutyCycle2: 0.5, icon: "leaf", duration: 600), // 10 minutes
        Preset(name: "High Blood Pressure", frequency1: 15.0, dutyCycle1: 0.6, frequency2: 10.0, dutyCycle2: 0.5, icon: "heart", duration: 900), // 15 minutes
        Preset(name: "Pain Relief", frequency1: 20.0, dutyCycle1: 0.5, frequency2: 5.0, dutyCycle2: 0.7, icon: "bandage", duration: 1200), // 20 minutes
        Preset(name: "Sleep Aid", frequency1: 4.0, dutyCycle1: 0.7, frequency2: 2.0, dutyCycle2: 0.6, icon: "moon.zzz", duration: 1800), // 30 minutes
        Preset(name: "Energy Boost", frequency1: 30.0, dutyCycle1: 0.5, frequency2: 25.0, dutyCycle2: 0.5, icon: "bolt", duration: 300), // 5 minutes
        Preset(name: "Stress Reduction", frequency1: 8.0, dutyCycle1: 0.6, frequency2: 6.0, dutyCycle2: 0.6, icon: "brain.head.profile", duration: 1200), // 20 minutes
        Preset(name: "Bone Healing", frequency1: 15.0, dutyCycle1: 0.5, frequency2: 72.0, dutyCycle2: 0.5, icon: "figure.walk", duration: 1800), // 30 minutes
        Preset(name: "Muscle Recovery", frequency1: 40.0, dutyCycle1: 0.5, frequency2: 35.0, dutyCycle2: 0.5, icon: "figure.run", duration: 1200) // 20 minutes
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(presets) { preset in
                    HStack {
                        Image(systemName: preset.icon)
                            .foregroundStyle(.blue)
                            .font(.title2)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text(preset.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Text("F1: \(preset.frequency1, specifier: "%.1f") Hz, Duty: \(Int(preset.dutyCycle1 * 100))%")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text("F2: \(preset.frequency2, specifier: "%.1f") Hz, Duty: \(Int(preset.dutyCycle2 * 100))%")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            if let timer = activePresets[preset.name] {
                                Text("Time remaining: \(formatTime(timer.timeRemaining))")
                                    .font(.subheadline)
                                    .foregroundStyle(.green)
                            }
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { activePresets[preset.name] != nil },
                            set: { newValue in
                                if newValue {
                                    startPreset(preset)
                                } else {
                                    stopPreset(preset)
                                }
                            }
                        ))
                        .labelsHidden()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Presets")
        }
    }
    
    private func startPreset(_ preset: Preset) {
        applyPreset(preset)
        let timer = PresetTimer(preset: preset) {
            stopPreset(preset)
        }
        activePresets[preset.name] = timer
        timer.start()
    }
    
    private func stopPreset(_ preset: Preset) {
        activePresets[preset.name]?.stop()
        activePresets.removeValue(forKey: preset.name)
        toneGenerator.stopTone1()
        toneGenerator.stopTone2()
    }
    
    private func applyPreset(_ preset: Preset) {
        toneGenerator.setFrequency1(preset.frequency1)
        toneGenerator.dutyCycle1 = preset.dutyCycle1
        toneGenerator.setFrequency2(preset.frequency2)
        toneGenerator.dutyCycle2 = preset.dutyCycle2
        toneGenerator.playTone1()
        toneGenerator.playTone2()
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    PresetFrequenciesView()
        .environment(ToneGenerator())
}
