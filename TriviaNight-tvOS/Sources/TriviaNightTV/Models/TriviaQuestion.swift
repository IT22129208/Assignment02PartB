import Foundation

public struct TriviaQuestion: Identifiable, Codable, Hashable {
    public let id: UUID
    public let category: TriviaCategoryType
    public let prompt: String
    public let options: [String]
    public let correctIndex: Int
    public let explanation: String
    public let basePoints: Int
    public let timeLimitSeconds: Int
    
    public init(
        id: UUID = UUID(),
        category: TriviaCategoryType,
        prompt: String,
        options: [String],
        correctIndex: Int,
        explanation: String,
        basePoints: Int = 1000,
        timeLimitSeconds: Int = 15
    ) {
        self.id = id
        self.category = category
        self.prompt = prompt
        self.options = options
        self.correctIndex = correctIndex
        self.explanation = explanation
        self.basePoints = basePoints
        self.timeLimitSeconds = timeLimitSeconds
    }
}
