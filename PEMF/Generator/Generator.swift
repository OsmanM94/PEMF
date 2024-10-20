//
//  Generator.swift
//  PEMF
//
//  Created by asia on 20.10.2024.
//

import Foundation
import AVFoundation

@Observable
final class ToneGenerator {
    private var audioEngine: AVAudioEngine
    private var toneGeneratorNode: AVAudioSourceNode!
    private var currentPhase1: Double = 0
    private var currentPhase2: Double = 0
    private var gain1: Float = 0.0
    private var gain2: Float = 0.0
    private var targetGain1: Float = 0.0
    private var targetGain2: Float = 0.0
    private let smoothness: Float = 0.005
    private var targetFrequency1: Double = 5.0
    private var targetFrequency2: Double = 40.0
    private let frequencySmoothing: Double = 0.01
    
    private(set) var isPlaying1 = false
    private(set) var isPlaying2 = false
    private(set) var frequency1: Double = 5.0
    private(set) var frequency2: Double = 40.0
    var dutyCycle1: Double = 0.5
    var dutyCycle2: Double = 0.5
    
    init() {
        audioEngine = AVAudioEngine()
        
        let outputNode = audioEngine.outputNode
        let format = outputNode.inputFormat(forBus: 0)
        
        toneGeneratorNode = AVAudioSourceNode { [weak self] (_, _, frameCount, audioBufferList) -> OSStatus in
            guard let self = self else { return noErr }
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            
            for frame in 0..<Int(frameCount) {
                self.gain1 += (self.targetGain1 - self.gain1) * self.smoothness
                self.gain2 += (self.targetGain2 - self.gain2) * self.smoothness
                let newFreq1 = self.frequency1 + (self.targetFrequency1 - self.frequency1) * self.frequencySmoothing
                let newFreq2 = self.frequency2 + (self.targetFrequency2 - self.frequency2) * self.frequencySmoothing
                
                DispatchQueue.main.async {
                    self.frequency1 = newFreq1
                    self.frequency2 = newFreq2
                }
                
                let phaseIncrement1 = 2.0 * .pi * newFreq1 / Double(format.sampleRate)
                let phaseIncrement2 = 2.0 * .pi * newFreq2 / Double(format.sampleRate)
                
                let value1 = self.generatePulse(phase: self.currentPhase1, dutyCycle: self.dutyCycle1) * Double(self.gain1)
                let value2 = self.generatePulse(phase: self.currentPhase2, dutyCycle: self.dutyCycle2) * Double(self.gain2)
                
                let combinedValue = (value1 + value2) / 2
                
                self.currentPhase1 += phaseIncrement1
                self.currentPhase2 += phaseIncrement2
                if self.currentPhase1 > 2.0 * .pi { self.currentPhase1 -= 2.0 * .pi }
                if self.currentPhase2 > 2.0 * .pi { self.currentPhase2 -= 2.0 * .pi }
                
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = Float(combinedValue)
                }
            }
            return noErr
        }
        
        let mainMixer = audioEngine.mainMixerNode
        
        audioEngine.attach(toneGeneratorNode)
        audioEngine.connect(toneGeneratorNode, to: mainMixer, format: format)
        audioEngine.connect(mainMixer, to: outputNode, format: format)
        
        do {
            try audioEngine.start()
        } catch {
            print("Could not start audio engine: \(error.localizedDescription)")
        }
    }
    
    private func generatePulse(phase: Double, dutyCycle: Double) -> Double {
        return phase / (2 * .pi) < dutyCycle ? 1.0 : -1.0
    }
    
    func setFrequency1(_ newValue: Double) {
        DispatchQueue.main.async {
            self.targetFrequency1 = newValue
        }
    }
    
    func setFrequency2(_ newValue: Double) {
        DispatchQueue.main.async {
            self.targetFrequency2 = newValue
        }
    }
    
    func playTone1() {
        DispatchQueue.main.async {
            self.targetGain1 = 1.0
            self.isPlaying1 = true
        }
    }
    
    func stopTone1() {
        DispatchQueue.main.async {
            self.targetGain1 = 0.0
            self.isPlaying1 = false
        }
    }
    
    func playTone2() {
        DispatchQueue.main.async {
            self.targetGain2 = 1.0
            self.isPlaying2 = true
        }
    }
    
    func stopTone2() {
        DispatchQueue.main.async {
            self.targetGain2 = 0.0
            self.isPlaying2 = false
        }
    }
}
