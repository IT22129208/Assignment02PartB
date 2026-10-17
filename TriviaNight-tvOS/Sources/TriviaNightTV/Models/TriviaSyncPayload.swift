import Foundation

public enum TriviaSyncPayload: Codable {
    case playerJoin(player: Player)
    case playerAnswer(playerId: String, answerIndex: Int, timeElapsed: Double)
    case hostStateUpdate(stateName: String, questionIndex: Int, timeRemaining: Double)
    case gameRestart
}
