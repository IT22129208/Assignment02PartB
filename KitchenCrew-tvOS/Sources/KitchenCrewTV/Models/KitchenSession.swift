import Foundation

public struct KitchenSession: Identifiable, Codable {
    public let id: String
    public let recipeId: String
    public var currentStepIndex: Int
    public var activeCameraAngle: CameraAngle
    public var isSplitScreen: Bool
    public var connectedChefs: [ChefUser]
    public var activeTimers: [KitchenTimer]
    public var isVoiceListening: Bool
    public var lastVoiceTranscript: String
    public var isPaused: Bool
    
    public init(
        id: String = UUID().uuidString,
        recipeId: String,
        currentStepIndex: Int = 0,
        activeCameraAngle: CameraAngle = .wideChef,
        isSplitScreen: Bool = false,
        connectedChefs: [ChefUser] = [],
        activeTimers: [KitchenTimer] = [],
        isVoiceListening: Bool = true,
        lastVoiceTranscript: String = "Kitchen microphone active: Say 'Hey Siri' or 'Next step'",
        isPaused: Bool = false
    ) {
        self.id = id
        self.recipeId = recipeId
        self.currentStepIndex = currentStepIndex
        self.activeCameraAngle = activeCameraAngle
        self.isSplitScreen = isSplitScreen
        self.connectedChefs = connectedChefs
        self.activeTimers = activeTimers
        self.isVoiceListening = isVoiceListening
        self.lastVoiceTranscript = lastVoiceTranscript
        self.isPaused = isPaused
    }
}

public enum SyncPayload: Codable {
    case stepChange(newIndex: Int)
    case taskCompleted(userId: String, taskId: String, newProgress: Double)
    case timerUpdate(timer: KitchenTimer)
    case timerAlert(timerId: UUID, message: String)
    case cameraAngleChanged(angle: CameraAngle)
    case ingredientSubstituted(ingredientName: String, substitution: String)
}
