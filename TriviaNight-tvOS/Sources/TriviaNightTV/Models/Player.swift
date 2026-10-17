import Foundation

public enum ControllerType: String, Codable, Hashable {
    case siriRemote = "Siri Remote (TV Host)"
    case companionPhone = "iPhone Controller"
}

public struct Player: Identifiable, Codable, Hashable {
    public let id: String
    public var name: String
    public var avatarIcon: String
    public var colorHex: String
    public var controllerType: ControllerType
    public var score: Int
    public var streak: Int
    public var highestStreak: Int
    public var correctAnswersCount: Int
    public var totalAnswersCount: Int
    public var selectedAnswerIndex: Int?
    public var isLockedIn: Bool
    public var answerTimeSeconds: Double?
    public var pointsAwardedLastRound: Int
    
    public init(
        id: String,
        name: String,
        avatarIcon: String,
        colorHex: String,
        controllerType: ControllerType = .companionPhone,
        score: Int = 0,
        streak: Int = 0,
        highestStreak: Int = 0,
        correctAnswersCount: Int = 0,
        totalAnswersCount: Int = 0,
        selectedAnswerIndex: Int? = nil,
        isLockedIn: Bool = false,
        answerTimeSeconds: Double? = nil,
        pointsAwardedLastRound: Int = 0
    ) {
        self.id = id
        self.name = name
        self.avatarIcon = avatarIcon
        self.colorHex = colorHex
        self.controllerType = controllerType
        self.score = score
        self.streak = streak
        self.highestStreak = highestStreak
        self.correctAnswersCount = correctAnswersCount
        self.totalAnswersCount = totalAnswersCount
        self.selectedAnswerIndex = selectedAnswerIndex
        self.isLockedIn = isLockedIn
        self.answerTimeSeconds = answerTimeSeconds
        self.pointsAwardedLastRound = pointsAwardedLastRound
    }
    
    public var accuracyPercentage: Double {
        guard totalAnswersCount > 0 else { return 0 }
        return (Double(correctAnswersCount) / Double(totalAnswersCount)) * 100
    }
    
    public static let initialLobbyPlayers: [Player] = [
        Player(
            id: "player-remote",
            name: "Sam (Host)",
            avatarIcon: "gamecontroller.fill",
            colorHex: "#38bdf8", // Sky blue
            controllerType: .siriRemote
        )
    ]
}
