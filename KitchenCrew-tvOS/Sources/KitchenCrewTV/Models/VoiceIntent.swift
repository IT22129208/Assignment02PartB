import Foundation

public enum VoiceIntent: Equatable {
    case nextStep
    case previousStep
    case repeatInstruction
    case startTimer(seconds: Int, label: String)
    case pauseResumeTimer(timerId: UUID?)
    case switchCamera(angle: CameraAngle)
    case toggleSplitScreen
    case querySubstitution(ingredient: String)
    case queryStationStatus(role: StationRole)
    case unknown(query: String)
}

public struct VoiceParser {
    public static func parse(transcript: String) -> VoiceIntent {
        let text = transcript.lowercased()
        
        // Navigation Intents
        if text.contains("next") || text.contains("done") || text.contains("continue") || text.contains("step complete") {
            return .nextStep
        }
        if text.contains("back") || text.contains("previous") {
            return .previousStep
        }
        if text.contains("repeat") || text.contains("what did he say") || text.contains("replay") {
            return .repeatInstruction
        }
        
        // Camera Angles
        if text.contains("pan") || text.contains("macro") || text.contains("sizzle") || text.contains("close up") {
            return .switchCamera(angle: .macroPan)
        }
        if text.contains("wide") || text.contains("chef") || text.contains("counter") {
            return .switchCamera(angle: .wideChef)
        }
        if text.contains("plating") || text.contains("overhead") {
            return .switchCamera(angle: .overheadPlating)
        }
        if text.contains("split screen") || text.contains("dual") || text.contains("both angles") {
            return .toggleSplitScreen
        }
        
        // Timer Parsing: e.g. "set timer for 9 minutes" or "90 seconds"
        if text.contains("timer") {
            var extractedSeconds = 60
            if let match = text.range(of: #"\d+"#, options: .regularExpression) {
                let numberString = String(text[match])
                if let num = Int(numberString) {
                    if text.contains("minute") || text.contains("min") {
                        extractedSeconds = num * 60
                    } else if text.contains("second") || text.contains("sec") {
                        extractedSeconds = num
                    } else {
                        extractedSeconds = num * 60
                    }
                }
            }
            
            var label = "Kitchen Timer"
            if text.contains("sear") || text.contains("scallop") { label = "Sear Scallops" }
            else if text.contains("cauliflower") || text.contains("simmer") { label = "Simmer Cauliflower" }
            else if text.contains("pancetta") { label = "Crisp Pancetta" }
            else if text.contains("basting") { label = "Butter Baste" }
            
            return .startTimer(seconds: extractedSeconds, label: label)
        }
        
        // Substitutions
        if text.contains("substitute") || text.contains("replacement") || text.contains("instead of") {
            return .querySubstitution(ingredient: text)
        }
        
        // Station Status
        if text.contains("prep") || text.contains("alex") {
            return .queryStationStatus(role: .prep)
        }
        if text.contains("saute") || text.contains("stove") || text.contains("sarah") {
            return .queryStationStatus(role: .saute)
        }
        
        return .unknown(query: transcript)
    }
}
