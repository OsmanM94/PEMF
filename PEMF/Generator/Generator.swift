
import Foundation
import AVFoundation
import MediaPlayer

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
    
    private var customFrequency1: Double = 5.0
    private var customFrequency2: Double = 40.0
    private var customDutyCycle1: Double = 0.5
    private var customDutyCycle2: Double = 0.5
    
    private var threshold: Float = 0.8
    private var ratio: Float = 4.0
    
    private var wasPlayingBeforeInterruption = false
    
    init() {
        audioEngine = AVAudioEngine()
        
        setupAudioSession()
        setupRemoteControlEvents()
        
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
                
                var finalValue = Float(combinedValue)
                if abs(finalValue) > self.threshold {
                    finalValue = self.threshold + (finalValue - self.threshold) / self.ratio
                }
                
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = finalValue
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
        
        setupNotificationObservers()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    private func setupRemoteControlEvents() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.handlePlayCommand()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.handlePauseCommand()
            return .success
        }
        
        updateNowPlayingInfo()
    }
    
    private func handlePlayCommand() {
        resetState()
        playTone1()
        playTone2()
    }
    
    private func handlePauseCommand() {
        stopTone1()
        stopTone2()
    }
    
    private func resetState() {
        currentPhase1 = 0
        currentPhase2 = 0
        gain1 = 0.0
        gain2 = 0.0
        targetGain1 = 0.0
        targetGain2 = 0.0
    }

    private func updateNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "PEMF Therapy"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Your App Name"
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        
        if isPlaying1 || isPlaying2 {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        } else {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)
    }

    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            wasPlayingBeforeInterruption = isPlaying1 || isPlaying2
            stopTone1()
            stopTone2()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt,
                  AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume) else {
                return
            }
            if wasPlayingBeforeInterruption {
                resetState()
                playTone1()
                playTone2()
            }
        @unknown default:
            break
        }
    }

    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        switch reason {
        case .oldDeviceUnavailable:
            stopTone1()
            stopTone2()
        default:
            break
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
            self.resetState()
            self.targetGain1 = 1.0
            self.isPlaying1 = true
            self.updateNowPlayingInfo()
        }
    }
    
    func stopTone1() {
        DispatchQueue.main.async {
            self.targetGain1 = 0.0
            self.isPlaying1 = false
            self.updateNowPlayingInfo()
        }
    }
    
    func playTone2() {
        DispatchQueue.main.async {
            self.resetState()
            self.targetGain2 = 1.0
            self.isPlaying2 = true
            self.updateNowPlayingInfo()
        }
    }
    
    func stopTone2() {
        DispatchQueue.main.async {
            self.targetGain2 = 0.0
            self.isPlaying2 = false
            self.updateNowPlayingInfo()
        }
    }
    
    func applyCustomSettings() {
        DispatchQueue.main.async {
            self.targetFrequency1 = self.customFrequency1
            self.targetFrequency2 = self.customFrequency2
            self.dutyCycle1 = self.customDutyCycle1
            self.dutyCycle2 = self.customDutyCycle2
        }
    }
    
    func saveCustomSettings() {
        customFrequency1 = frequency1
        customFrequency2 = frequency2
        customDutyCycle1 = dutyCycle1
        customDutyCycle2 = dutyCycle2
    }
    
    func applyPresetSettings(frequency1: Double, dutyCycle1: Double, frequency2: Double, dutyCycle2: Double, threshold: Float, ratio: Float) {
        DispatchQueue.main.async {
            self.targetFrequency1 = frequency1
            self.targetFrequency2 = frequency2
            self.dutyCycle1 = dutyCycle1
            self.dutyCycle2 = dutyCycle2
            self.threshold = threshold
            self.ratio = ratio
        }
    }
    
    func resetToDefaults() {
        DispatchQueue.main.async {
            self.stopTone1()
            self.stopTone2()
            self.targetFrequency1 = 5.0
            self.targetFrequency2 = 40.0
            self.dutyCycle1 = 0.5
            self.dutyCycle2 = 0.5
            self.threshold = 0.8
            self.ratio = 4.0
        }
    }
}
