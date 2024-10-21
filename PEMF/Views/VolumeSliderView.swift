import SwiftUI
import MediaPlayer
import AVFoundation
import Combine

@Observable
class VolumeObserver {
    var volume: Float = 0.0
    private var cancellable: AnyCancellable?
    
    init() {
        setupVolumeObserver()
    }
    
    private func setupVolumeObserver() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Initial volume check
            volume = AVAudioSession.sharedInstance().outputVolume
            
            cancellable = AVAudioSession.sharedInstance().publisher(for: \.outputVolume)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newVolume in
                    self?.volume = newVolume
                }
        } catch {
            print("Failed to set up volume observer: \(error)")
        }
    }
}

struct VolumeAlertView: View {
    @Binding var isPresented: Bool
    
    @Environment(VolumeObserver.self) private var volumeObserver
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color(.systemGray6))
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 20) {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue)
                    
                    Text("Volume")
                        .font(.title2.bold())
                    
                    Text("You must set your device volume to maximum.")
                        .multilineTextAlignment(.center)
                }
                
                VolumeSliderView()
                    .frame(height: 40)
                    .padding()
                    .padding(.horizontal, 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button("OK") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.extraLarge)
                .disabled(volumeObserver.volume < 0.99) // Disable if not at max volume
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
        }
    }
}

struct VolumeSliderView: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        let volumeView = MPVolumeView()
        volumeView.showsVolumeSlider = true
        volumeView.tintColor = .systemBlue
        return volumeView
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context) {
        // No update needed
    }
}
