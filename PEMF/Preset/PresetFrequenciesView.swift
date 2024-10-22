
import SwiftUI

struct PresetFrequenciesView: View {
    @Environment(ToneGenerator.self) private var toneGenerator
    @State private var activePresets: [String: PresetTimer] = [:]
    
    let presets: [Preset] = [
        Preset(
            name: "Relaxation",
            frequency1: 138.59,
            dutyCycle1: 0.3,
            frequency2: 4.00,
            dutyCycle2: 0.3,
            icon: "leaf",
            duration: 5400,
            threshold: 0.8,
            ratio: 4.0
        ),
        Preset(
            name: "Osteoporosis",
            frequency1: 50.0,
            dutyCycle1: 0.4,
            frequency2: 123.0,
            dutyCycle2: 0.41,
            icon: "figure.walk",
            duration: 5400,
            threshold: 0.8,
            ratio: 4.0
        ),
        Preset(
            name: "Pain Relief",
            frequency1: 50.0,
            dutyCycle1: 0.4,
            frequency2: 7.0,
            dutyCycle2: 0.4,
            icon: "bandage",
            duration: 5400,
            threshold: 0.8,
            ratio: 4.0
        ),
        Preset(
            name: "Sleep Aid",
            frequency1: 3.0,
            dutyCycle1: 0.3,
            frequency2: 174.0,
            dutyCycle2: 0.2,
            icon: "moon.zzz",
            duration: 1800,
            threshold: 0.8,
            ratio: 4.0
        ),
        Preset(
            name: "Energy Boost",
            frequency1: 261.63,
            dutyCycle1: 0.3,
            frequency2: 14.0,
            dutyCycle2: 0.3,
            icon: "bolt",
            duration: 5400,
            threshold: 0.8,
            ratio: 4.0
        ),
        Preset(
            name: "Concentration",
            frequency1: 123.47,
            dutyCycle1: 0.3,
            frequency2: 23.0,
            dutyCycle2: 0.3,
            icon: "brain.head.profile",
            duration: 5400,
            threshold: 0.8,
            ratio: 4.0
        ),
        Preset(
            name: "Migraine",
            frequency1: 10.0,
            dutyCycle1: 0.43,
            frequency2: 1.0,
            dutyCycle2: 0.4,
            icon: "head.profile.arrow.forward.and.visionpro",
            duration: 1800,
            threshold: 0.8,
            ratio: 3.0
        ),
        Preset(
            name: "Muscle Recovery",
            frequency1: 174.0,
            dutyCycle1: 0.5,
            frequency2: 7.83,
            dutyCycle2: 0.4,
            icon: "figure.run",
            duration: 5400,
            threshold: 0.8,
            ratio: 4.0
        ),
        Preset(
            name: "Creativity",
            frequency1: 110.00,
            dutyCycle1: 0.3,
            frequency2: 6.0,
            dutyCycle2: 0.3,
            icon: "paintpalette.fill",
            duration: 5400,
            threshold: 0.8,
            ratio: 4.0
        ),
        Preset(
            name: "Healing",
            frequency1: 432.00,
            dutyCycle1: 0.4,
            frequency2: 7.83,
            dutyCycle2: 0.4,
            icon: "leaf.fill",
            duration: 5400,
            threshold: 0.8,
            ratio: 4.0
        )
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(presets) { preset in
                    HStack(spacing: 15) {
                        Image(systemName: preset.icon)
                            .foregroundStyle(.blue)
                            .font(.title2)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text(preset.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
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
        .onDisappear {
            stopAllPresets()
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
        toneGenerator.resetToDefaults()
    }
    
    private func applyPreset(_ preset: Preset) {
        toneGenerator.applyPresetSettings(
            frequency1: preset.frequency1,
            dutyCycle1: preset.dutyCycle1,
            frequency2: preset.frequency2,
            dutyCycle2: preset.dutyCycle2,
            threshold: preset.threshold,
            ratio: preset.ratio
        )
        toneGenerator.playTone1()
        toneGenerator.playTone2()
    }
    
    private func stopAllPresets() {
        for preset in activePresets.keys {
            if let preset = presets.first(where: { $0.name == preset }) {
                stopPreset(preset)
            }
        }
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



//                            Text("F1: \(preset.frequency1, specifier: "%.2f") Hz, Duty: \(Int(preset.dutyCycle1 * 100))%")
//                                .font(.subheadline)
//                                .foregroundStyle(.secondary)
//
//                            Text("F2: \(preset.frequency2, specifier: "%.2f") Hz, Duty: \(Int(preset.dutyCycle2 * 100))%")
//                                .font(.subheadline)
//                                .foregroundStyle(.secondary)
//
//                            Text("Threshold: \(preset.threshold, specifier: "%.1f"), Ratio: \(preset.ratio, specifier: "%.1f")")
//                                .font(.subheadline)
//                                .foregroundStyle(.secondary)
