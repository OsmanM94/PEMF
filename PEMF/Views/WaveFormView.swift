//
//  WaveFormView.swift
//  PEMF
//
//  Created by asia on 21.10.2024.
//

import SwiftUI

struct WaveformView: View {
    let frequency: Double
    let width: CGFloat
    let height: CGFloat
    let isPlaying: Bool
    let speedFactor: Double 
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let timeInterval = timeline.date.timeIntervalSinceReferenceDate
                let phase = isPlaying ? timeInterval * speedFactor * frequency * 2 * Double.pi : 0
                
                let midHeight = height / 2
                let wavelength = width / (frequency / 10) // Adjust this factor to fit more or fewer waves
                
                var path = Path()
                path.move(to: CGPoint(x: 0, y: midHeight))
                
                for x in stride(from: 0, through: width, by: 1) {
                    let relativeX = x / wavelength
                    let y = sin(relativeX * 2 * Double.pi + phase) * midHeight * 0.9 + midHeight
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                
                context.stroke(path, with: .color(.blue), lineWidth: 2)
            }
        }
        .frame(width: width, height: height)
        .opacity(isPlaying ? 1 : 0.5) // Dim the waveform when not playing
    }
}

#Preview {
    WaveformView(frequency: 5.0, width: 50, height: 50, isPlaying: true, speedFactor: 0.2)
}
