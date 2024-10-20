
import SwiftUI

struct PresetFrequenciesView: View {
    @Environment(ToneGenerator.self) private var toneGenerator
    @State private var activePresets: Set<String> = []
    
    let presets: [(String, Double, Double, Double, Double, String)] = [
        ("Relaxation", 10.0, 0.5, 7.83, 0.5, "leaf"),
        ("High Blood Pressure", 15.0, 0.6, 10.0, 0.5, "heart"),
        ("Pain Relief", 20.0, 0.5, 5.0, 0.7, "bandage"),
        ("Sleep Aid", 4.0, 0.7, 2.0, 0.6, "moon.zzz"),
        ("Energy Boost", 30.0, 0.5, 25.0, 0.5, "bolt"),
        ("Stress Reduction", 8.0, 0.6, 6.0, 0.6, "brain.head.profile"),
        ("Bone Healing", 15.0, 0.5, 72.0, 0.5, "figure.walk"),
        ("Muscle Recovery", 40.0, 0.5, 35.0, 0.5, "figure.run")
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(presets, id: \.0) { preset in
                    HStack {
                        Image(systemName: preset.5)
                            .foregroundColor(.blue)
                            .font(.title2)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text(preset.0)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
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
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Presets")
        }
    }
    
    private func applyPreset(_ preset: (String, Double, Double, Double, Double, String)) {
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

