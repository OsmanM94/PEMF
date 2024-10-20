

import SwiftUI

@Observable
final class TimerManager {
    var secondsElapsed = 0
    var timerActive = false
    private var timer: Timer?
    
    func startTimer() {
        timerActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.secondsElapsed += 1
        }
    }
    
    func stopTimer() {
        timerActive = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        stopTimer()
        secondsElapsed = 0
    }
    
    deinit {
        timer?.invalidate()
    }
}

struct TimerView: View {
    @State private var timerManager = TimerManager()
    
    @Environment(ToneGenerator.self) private var toneGenerator
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSession = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(timeString(from: timerManager.secondsElapsed))
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                    .foregroundStyle(.blue)
                
                HStack(spacing: 30) {
                    Button(action: {
                        if timerManager.timerActive {
                            timerManager.stopTimer()
                        } else {
                            timerManager.startTimer()
                        }
                    }) {
                        Text(timerManager.timerActive ? "Stop" : "Start")
                            .font(.title3)
                            .foregroundStyle(timerManager.timerActive ? Color.red : Color.green)
                            
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.extraLarge)
                    
                    Button(action: {
                        timerManager.resetTimer()
                    }) {
                        Text("Reset")
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.extraLarge)
                    
                }
            }
            .navigationTitle("Timer")
            .padding()
            .sheet(isPresented: $showingAddSession) {
                AddSessionView(duration: TimeInterval(timerManager.secondsElapsed))
            }
            
            if !timerManager.timerActive && timerManager.secondsElapsed > 0 {
                Button(action: {
                    showingAddSession = true
                }) {
                    Text("Save")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.extraLarge)
            }
        }
    }
    
    func timeString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    TimerView()
        .environment(ToneGenerator())
}
