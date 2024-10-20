
import SwiftUI

struct CustomGeneratorView: View {
    @Environment(ToneGenerator.self) private var toneGenerator
    
    @State private var sliderFrequency1: Double = 5.00
    @State private var sliderFrequency2: Double = 40.0
    
    private let frequencyStep: Double = 0.01
    private let fastFrequencyStep: Double = 0.1
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                frequencyControl(frequency: $sliderFrequency1,
                                 dutyCycle: Bindable(toneGenerator).dutyCycle1,
                                 title: "Frequency 1",
                                 setFrequency: toneGenerator.setFrequency1,
                                 isPlaying: toneGenerator.isPlaying1,
                                 playTone: toneGenerator.playTone1,
                                 stopTone: toneGenerator.stopTone1)
               
                frequencyControl(frequency: $sliderFrequency2,
                                 dutyCycle: Bindable(toneGenerator).dutyCycle2,
                                 title: "Frequency 2",
                                 setFrequency: toneGenerator.setFrequency2,
                                 isPlaying: toneGenerator.isPlaying2,
                                 playTone: toneGenerator.playTone2,
                                 stopTone: toneGenerator.stopTone2)
                
                Text("Design by Osman Sevil")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    .padding()
            }
            .navigationTitle("PEMF")
        }
    }
    
    private func frequencyControl(frequency: Binding<Double>, dutyCycle: Binding<Double>, title: String, setFrequency: @escaping (Double) -> Void, isPlaying: Bool, playTone: @escaping () -> Void, stopTone: @escaping () -> Void) -> some View {
        VStack(spacing: 20) {
            HStack {
                FrequencyButton(systemName: "minus.circle.fill", action: {
                    adjustFrequency(frequency: frequency, setFrequency: setFrequency, increment: false)
                }, longPressAction: {
                    adjustFrequency(frequency: frequency, setFrequency: setFrequency, increment: false, isFast: true)
                })
                .sensoryFeedback(.decrease, trigger: frequency.wrappedValue)
                
                Text("\(frequency.wrappedValue, specifier: "%.2f") Hz")
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: 120)
                
                FrequencyButton(systemName: "plus.circle.fill", action: {
                    adjustFrequency(frequency: frequency, setFrequency: setFrequency, increment: true)
                }, longPressAction: {
                    adjustFrequency(frequency: frequency, setFrequency: setFrequency, increment: true, isFast: true)
                })
                .sensoryFeedback(.increase, trigger: frequency.wrappedValue)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            HStack {
                Slider(value: frequency, in: 0...5000, step: 0.1)
                    .frame(width: 220)
                    .onChange(of: frequency.wrappedValue) { _, newValue in
                        setFrequency(newValue)
                    }
                
                Toggle(isOn: Binding<Bool>(
                    get: { isPlaying },
                    set: { newValue in
                        if newValue {
                            playTone()
                        } else {
                            stopTone()
                        }
                    }
                )) {
                    Text(isPlaying ? "ON" : "OFF")
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .labelsHidden()
                .sensoryFeedback(.impact, trigger: isPlaying)
            }
            
            HStack {
                Text("Duty: \((dutyCycle.wrappedValue * 100).rounded(), specifier: "%.0f")%")
                Slider(value: dutyCycle, in: 0.05...0.85, step: 0.01)
                    .frame(width: 200)
            }
        }
    }
    
    private func adjustFrequency(frequency: Binding<Double>, setFrequency: (Double) -> Void, increment: Bool, isFast: Bool = false) {
        let step = isFast ? fastFrequencyStep : frequencyStep
        let newValue = increment ?
            min(5000, frequency.wrappedValue + step) :
            max(0, frequency.wrappedValue - step)
        frequency.wrappedValue = newValue
        setFrequency(newValue)
    }
}

struct FrequencyButton: View {
    let systemName: String
    let action: () -> Void
    let longPressAction: () -> Void
    
    @State private var timer: Timer?
    @State private var isLongPressing = false
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 44))
            .foregroundColor(.blue)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isLongPressing {
                            isLongPressing = true
                            action()
                            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                                longPressAction()
                            }
                        }
                    }
                    .onEnded { _ in
                        isLongPressing = false
                        timer?.invalidate()
                        timer = nil
                    }
            )
    }
}

#Preview {
    NavigationStack {
        CustomGeneratorView()
            .environment(ToneGenerator())
    }
}

