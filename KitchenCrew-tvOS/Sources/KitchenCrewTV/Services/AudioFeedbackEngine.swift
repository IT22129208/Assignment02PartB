import Foundation
import AudioToolbox
import AVFoundation

public final class AudioFeedbackEngine {
    public static let shared = AudioFeedbackEngine()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    public enum SoundEffect {
        case focusNavigation
        case stepCompleted
        case stationPeerJoined
        case timerDing
        case warningPulse
    }
    
    public func play(_ sound: SoundEffect) {
        switch sound {
        case .focusNavigation:
            AudioServicesPlaySystemSound(1104) // Standard tvOS subtle tick
        case .stepCompleted:
            AudioServicesPlaySystemSound(1025) // Celebratory chord
        case .stationPeerJoined:
            AudioServicesPlaySystemSound(1001) // Companion connect chime
        case .timerDing:
            AudioServicesPlaySystemSound(1005) // Kitchen bell alarm
        case .warningPulse:
            AudioServicesPlaySystemSound(1053) // Alert beep
        }
    }
}
