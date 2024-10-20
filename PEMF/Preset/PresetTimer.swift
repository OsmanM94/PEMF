//
//  ActivePresets.swift
//  PEMF
//
//  Created by asia on 20.10.2024.
//

import Foundation

@Observable
class PresetTimer {
    var timeRemaining: TimeInterval
    private var timer: Timer?
    private let preset: Preset
    private let onComplete: () -> Void
    
    init(preset: Preset, onComplete: @escaping () -> Void) {
        self.preset = preset
        self.timeRemaining = preset.duration
        self.onComplete = onComplete
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stop()
                self.onComplete()
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
