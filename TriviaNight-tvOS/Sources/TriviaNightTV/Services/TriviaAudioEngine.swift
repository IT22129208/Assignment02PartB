import Foundation
import AudioToolbox
import AVFoundation

public final class TriviaAudioEngine {
    public static let shared = TriviaAudioEngine()
    
    private init() {}
    
    public enum SoundEffect {
        case focusClick
        case timerTick
        case buzzerLocked
        case correctFanfare
        case wrongBuzzer
        case roundEndChime
        case victoryPodium
    }
    
    public func play(_ sound: SoundEffect) {
        switch sound {
        case .focusClick:
            AudioServicesPlaySystemSound(1104) // tvOS subtle click
        case .timerTick:
            AudioServicesPlaySystemSound(1103) // Clock tick
        case .buzzerLocked:
            AudioServicesPlaySystemSound(1001) // Lock-in chime
        case .correctFanfare:
            AudioServicesPlaySystemSound(1025) // Celebratory chord
        case .wrongBuzzer:
            AudioServicesPlaySystemSound(1053) // Low alert thud
        case .roundEndChime:
            AudioServicesPlaySystemSound(1005) // Bell alert
        case .victoryPodium:
            AudioServicesPlaySystemSound(1026) // Grand fanfare
        }
    }
}
