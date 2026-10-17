import Foundation
import Speech
import AVFoundation
import Combine

public final class KitchenVoiceService: ObservableObject {
    public static let shared = KitchenVoiceService()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published public var isListening: Bool = false
    @Published public var liveTranscript: String = "Listening for hands-free kitchen commands..."
    @Published public var detectedIntent: VoiceIntent?
    @Published public var audioLevel: Float = 0.0
    
    public init() {}
    
    public func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    completion(true)
                default:
                    completion(false)
                }
            }
        }
    }
    
    public func startListening() throws {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create recognition request")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        // Tailored contextual keywords for high-noise kitchen environments
        recognitionRequest.contextualStrings = [
            "KitchenCrew", "Next step", "Previous step", "Timer",
            "Scallops", "Pan angle", "Wide shot", "Substitute",
            "Cauliflower", "Pancetta", "Shallots", "Basting"
        ]
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            
            // Calculate audio power level for Siri-like waveform animation
            if let channelData = buffer.floatChannelData?[0] {
                let channelDataValue = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
                var sum: Float = 0
                for v in channelDataValue { sum += abs(v) }
                let avg = sum / Float(buffer.frameLength)
                DispatchQueue.main.async {
                    self?.audioLevel = min(max(avg * 10, 0.05), 1.0)
                }
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        self.isListening = true
        self.liveTranscript = "Kitchen voice conductor listening..."
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let transcript = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.liveTranscript = transcript
                    let intent = VoiceParser.parse(transcript: transcript)
                    if intent != .unknown(query: transcript) {
                        self.detectedIntent = intent
                    }
                }
            }
            
            if error != nil || result?.isFinal == true {
                self.stopListening()
            }
        }
    }
    
    public func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        self.isListening = false
        self.recognitionRequest = nil
        self.recognitionTask = nil
    }
}
