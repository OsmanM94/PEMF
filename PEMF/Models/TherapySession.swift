//
//  TherapySession.swift
//  PEMF
//
//  Created by asia on 20.10.2024.
//

import Foundation
import SwiftData

@Model
class TherapySession {
    var date: Date
    var duration: TimeInterval
    var frequency1: Double
    var frequency2: Double
    var preset: String?
    var notes: String
    
    init(date: Date, duration: TimeInterval, frequency1: Double, frequency2: Double, preset: String? = nil, notes: String) {
        self.date = date
        self.duration = duration
        self.frequency1 = frequency1
        self.frequency2 = frequency2
        self.preset = preset
        self.notes = notes
    }
}
