
import Foundation

struct Preset: Identifiable {
    let id = UUID()
    let name: String
    let frequency1: Double
    let dutyCycle1: Double
    let frequency2: Double
    let dutyCycle2: Double
    let icon: String
    let duration: TimeInterval // Duration in seconds
}
