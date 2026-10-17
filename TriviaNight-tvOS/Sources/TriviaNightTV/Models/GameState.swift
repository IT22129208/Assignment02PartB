import Foundation

public enum GameState: Equatable {
    case lobby
    case categorySelect
    case questionCountdown(secondsRemaining: Int)
    case questionActive
    case answerReveal
    case roundScoreboard
    case finalPodium
    
    public var screenTitle: String {
        switch self {
        case .lobby: return "Living Room Pub Quiz Lobby"
        case .categorySelect: return "Select Tonight's Trivia Pack"
        case .questionCountdown: return "Get Ready!"
        case .questionActive: return "Fastest Answer Wins Extra Points!"
        case .answerReveal: return "Answer Breakdown"
        case .roundScoreboard: return "Leaderboard Standings"
        case .finalPodium: return "Pub Quiz Champions!"
        }
    }
}
