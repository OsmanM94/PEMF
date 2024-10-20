
import SwiftUI

struct PresetFrequenciesView: View {
    @Environment(ToneGenerator.self) private var toneGenerator
    @State private var activePresets: Set<String> = []
    
    let presets: [(String, Double, Double, Double, Double)] = [
        ("Relaxation", 10.0, 0.5, 7.83, 0.5),
        ("High Blood Pressure", 15.0, 0.6, 10.0, 0.5),
        ("Pain Relief", 20.0, 0.5, 5.0, 0.7),
        ("Sleep Aid", 4.0, 0.7, 2.0, 0.6),
        ("Energy Boost", 30.0, 0.5, 25.0, 0.5),
        ("Stress Reduction", 8.0, 0.6, 6.0, 0.6),
        ("Bone Healing", 15.0, 0.5, 72.0, 0.5),
        ("Muscle Recovery", 40.0, 0.5, 35.0, 0.5)
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(presets, id: \.0) { preset in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(preset.0)
                                .font(.headline)
                                .foregroundStyle(.blue)
                            
                            Text("F1: \(preset.1, specifier: "%.1f") Hz, Duty: \(Int(preset.2 * 100))%")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text("F2: \(preset.3, specifier: "%.1f") Hz, Duty: \(Int(preset.4 * 100))%")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { activePresets.contains(preset.0) },
                            set: { newValue in
                                if newValue {
                                    activePresets.insert(preset.0)
                                    applyPreset(preset)
                                } else {
                                    activePresets.remove(preset.0)
                                    stopPreset()
                                }
                            }
                        ))
                        .labelsHidden()
                    }
                }
            }
            .navigationTitle("Presets")
        }
    }
    
    private func applyPreset(_ preset: (String, Double, Double, Double, Double)) {
        toneGenerator.setFrequency1(preset.1)
        toneGenerator.dutyCycle1 = preset.2
        toneGenerator.setFrequency2(preset.3)
        toneGenerator.dutyCycle2 = preset.4
        toneGenerator.playTone1()
        toneGenerator.playTone2()
    }
    
    private func stopPreset() {
        toneGenerator.stopTone1()
        toneGenerator.stopTone2()
    }
}

#Preview {
    PresetFrequenciesView()
        .environment(ToneGenerator())
}

