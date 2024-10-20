
import Foundation

struct Preset: Identifiable {
    let id = UUID()
    let name: String
    let frequency1: Double
    let dutyCycle1: Double
    let frequency2: Double
    let dutyCycle2: Double
    let icon: String
    let duration: TimeInterval
    let threshold: Float
    let ratio: Float

    init(name: String, frequency1: Double, dutyCycle1: Double, frequency2: Double, dutyCycle2: Double, icon: String, duration: TimeInterval, threshold: Float = 0.8, ratio: Float = 4.0) {
        self.name = name
        self.frequency1 = frequency1
        self.dutyCycle1 = dutyCycle1
        self.frequency2 = frequency2
        self.dutyCycle2 = dutyCycle2
        self.icon = icon
        self.duration = duration
        self.threshold = threshold
        self.ratio = ratio
    }
}
