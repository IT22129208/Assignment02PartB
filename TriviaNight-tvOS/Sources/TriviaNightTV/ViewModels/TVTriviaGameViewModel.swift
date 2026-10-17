import Foundation
import SwiftUI
import Combine

@MainActor
public final class TVTriviaGameViewModel: ObservableObject {
    @Published public var gameState: GameState = .lobby
    @Published public var categories: [TriviaCategory] = TriviaCategory.samplePacks
    @Published public var selectedCategory: TriviaCategory = TriviaCategory.samplePacks[0]
    @Published public var currentQuestionIndex: Int = 0
    @Published public var players: [Player] = Player.initialLobbyPlayers
    
    // Countdown Timer State
    @Published public var timeRemaining: Double = 15.0
    @Published public var totalQuestionTime: Double = 15.0
    @Published public var isTimerRunning: Bool = false
    
    // Active Toast Banner
    @Published public var activeToastMessage: String?
    @Published public var activeToastColorHex: String = "#38bdf8"
    
    private var timerTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    private let syncManager = TriviaSyncManager.shared
    private let audioEngine = TriviaAudioEngine.shared
    
    public init() {
        bindSyncManager()
    }
    
    public var currentQuestion: TriviaQuestion {
        let qs = selectedCategory.questions
        guard currentQuestionIndex >= 0 && currentQuestionIndex < qs.count else {
            return qs[0]
        }
        return qs[currentQuestionIndex]
    }
    
    public var currentRoundNumber: Int {
        currentQuestionIndex + 1
    }
    
    public var totalQuestionsInPack: Int {
        selectedCategory.questions.count
    }
    
    public var timerProgress: Double {
        guard totalQuestionTime > 0 else { return 0 }
        return max(0, min(1.0, timeRemaining / totalQuestionTime))
    }
    
    public var rankedPlayers: [Player] {
        players.sorted { $0.score > $1.score }
    }
    
    public var allPlayersLockedIn: Bool {
        players.allSatisfy { $0.isLockedIn }
    }
    
    // MARK: - Game Flow
    
    public func navigateToCategorySelect() {
        audioEngine.play(.focusClick)
        gameState = .categorySelect
    }
    
    public func selectCategory(_ category: TriviaCategory) {
        self.selectedCategory = category
        audioEngine.play(.buzzerLocked)
        startTriviaRound()
    }
    
    public func startTriviaRound() {
        currentQuestionIndex = 0
        resetPlayersForNewRound()
        startQuestionCountdown()
    }
    
    private func resetPlayersForNewRound() {
        for i in players.indices {
            players[i].selectedAnswerIndex = nil
            players[i].isLockedIn = false
            players[i].answerTimeSeconds = nil
            players[i].pointsAwardedLastRound = 0
        }
    }
    
    public func startQuestionCountdown() {
        audioEngine.play(.roundEndChime)
        gameState = .questionCountdown(secondsRemaining: 3)
        
        Task {
            for count in stride(from: 3, through: 1, by: -1) {
                self.gameState = .questionCountdown(secondsRemaining: count)
                self.audioEngine.play(.timerTick)
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            self.beginQuestion()
        }
    }
    
    public func beginQuestion() {
        resetPlayersForNewRound()
        timeRemaining = Double(currentQuestion.timeLimitSeconds)
        totalQuestionTime = Double(currentQuestion.timeLimitSeconds)
        isTimerRunning = true
        gameState = .questionActive
        
        broadcastHostState()
        startCountdownTimer()
    }
    
    private func startCountdownTimer() {
        timerTask?.cancel()
        timerTask = Task {
            while self.isTimerRunning && self.timeRemaining > 0 {
                try? await Task.sleep(nanoseconds: 100_000_000) // 100ms precision
                if Task.isCancelled { break }
                
                self.timeRemaining = max(0, self.timeRemaining - 0.1)
                
                // Audio tick on whole seconds when urgent
                if self.timeRemaining <= 5.0 && self.timeRemaining > 0 {
                    let rounded = round(self.timeRemaining * 10) / 10
                    if rounded.truncatingRemainder(dividingBy: 1.0) == 0 {
                        self.audioEngine.play(.timerTick)
                    }
                }
                
                if self.timeRemaining <= 0 {
                    self.timeRemaining = 0
                    self.isTimerRunning = false
                    self.evaluateRoundAnswers()
                    break
                }
            }
        }
    }
    
    // MARK: - Player Buzzer & Locking In
    
    public func lockInAnswer(playerId: String, answerIndex: Int) {
        guard gameState == .questionActive else { return }
        guard let idx = players.firstIndex(where: { $0.id == playerId }) else { return }
        guard !players[idx].isLockedIn else { return }
        
        let elapsed = totalQuestionTime - timeRemaining
        players[idx].selectedAnswerIndex = answerIndex
        players[idx].isLockedIn = true
        players[idx].answerTimeSeconds = elapsed
        
        audioEngine.play(.buzzerLocked)
        showToast("\(players[idx].name) locked in! (\(String(format: "%.1f", elapsed))s)", colorHex: players[idx].colorHex)
        
        // Auto-end question if all players locked in
        if allPlayersLockedIn {
            timerTask?.cancel()
            isTimerRunning = false
            evaluateRoundAnswers()
        }
    }
    
    private func evaluateRoundAnswers() {
        timerTask?.cancel()
        isTimerRunning = false
        
        let correctIdx = currentQuestion.correctIndex
        var anyCorrect = false
        
        for i in players.indices {
            players[i].totalAnswersCount += 1
            if players[i].selectedAnswerIndex == correctIdx {
                anyCorrect = true
                players[i].correctAnswersCount += 1
                players[i].streak += 1
                if players[i].streak > players[i].highestStreak {
                    players[i].highestStreak = players[i].streak
                }
                
                // Speed Bonus: Answering in first 3s gives up to 500 extra points
                let time = players[i].answerTimeSeconds ?? totalQuestionTime
                let speedFactor = max(0.0, (totalQuestionTime - time) / totalQuestionTime)
                let speedBonus = Int(speedFactor * 500)
                
                // Streak Multiplier: +10% per consecutive correct answer up to 2x
                let streakMultiplier = 1.0 + min(1.0, Double(players[i].streak - 1) * 0.25)
                let earnedPoints = Int(Double(currentQuestion.basePoints + speedBonus) * streakMultiplier)
                
                players[i].pointsAwardedLastRound = earnedPoints
                players[i].score += earnedPoints
            } else {
                players[i].streak = 0
                players[i].pointsAwardedLastRound = 0
            }
        }
        
        if anyCorrect {
            audioEngine.play(.correctFanfare)
        } else {
            audioEngine.play(.wrongBuzzer)
        }
        
        gameState = .answerReveal
    }
    
    public func proceedFromAnswerReveal() {
        audioEngine.play(.focusClick)
        gameState = .roundScoreboard
    }
    
    public func nextRoundOrFinish() {
        audioEngine.play(.focusClick)
        if currentQuestionIndex < totalQuestionsInPack - 1 {
            currentQuestionIndex += 1
            startQuestionCountdown()
        } else {
            audioEngine.play(.victoryPodium)
            gameState = .finalPodium
        }
    }
    
    public func restartToLobby() {
        audioEngine.play(.focusClick)
        for i in players.indices {
            players[i].score = 0
            players[i].streak = 0
            players[i].highestStreak = 0
            players[i].correctAnswersCount = 0
            players[i].totalAnswersCount = 0
            players[i].selectedAnswerIndex = nil
            players[i].isLockedIn = false
            players[i].pointsAwardedLastRound = 0
        }
        currentQuestionIndex = 0
        gameState = .lobby
    }
    
    // MARK: - Toast Banner
    public func showToast(_ message: String, colorHex: String = "#38bdf8") {
        self.activeToastMessage = message
        self.activeToastColorHex = colorHex
        
        Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if self.activeToastMessage == message {
                self.activeToastMessage = nil
            }
        }
    }
    
    // MARK: - Multipeer Connectivity Integration
    private func bindSyncManager() {
        syncManager.$receivedPayload
            .compactMap { $0 }
            .sink { [weak self] payload in
                self?.handleRemotePayload(payload)
            }
            .store(in: &cancellables)
    }
    
    private func handleRemotePayload(_ payload: TriviaSyncPayload) {
        switch payload {
        case .playerJoin(let player):
            if let idx = players.firstIndex(where: { $0.id == player.id || $0.controllerType == .companionPhone }) {
                players[idx].id = player.id
                players[idx].name = player.name
                players[idx].avatarIcon = player.avatarIcon
                players[idx].colorHex = player.colorHex
                audioEngine.play(.buzzerLocked)
                showToast("👋 \(player.name) synced on iPhone!", colorHex: player.colorHex)
            } else {
                players.append(player)
                audioEngine.play(.buzzerLocked)
                showToast("👋 \(player.name) joined the living room!", colorHex: player.colorHex)
            }
        case .playerAnswer(let playerId, let answerIndex, _):
            lockInAnswer(playerId: playerId, answerIndex: answerIndex)
        case .gameRestart:
            restartToLobby()
        default:
            break
        }
    }
    
    private func broadcastHostState() {
        let payload = TriviaSyncPayload.hostStateUpdate(
            stateName: "active",
            questionIndex: currentQuestionIndex,
            timeRemaining: timeRemaining
        )
        syncManager.broadcast(payload: payload)
    }
}
