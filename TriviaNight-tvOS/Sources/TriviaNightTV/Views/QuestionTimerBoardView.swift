import SwiftUI

public struct QuestionTimerBoardView: View {
    @ObservedObject var viewModel: TVTriviaGameViewModel
    @FocusState private var focusedAnswerIndex: Int?
    
    private let optionLetters = ["A", "B", "C", "D"]
    private let optionColors = [
        Color(hex: "#f43f5e"), // A: Rose
        Color(hex: "#0ea5e9"), // B: Sky
        Color(hex: "#eab308"), // C: Amber
        Color(hex: "#a855f7")  // D: Violet
    ]
    
    public init(viewModel: TVTriviaGameViewModel) {
        self.viewModel = viewModel
    }
    
    private var isUrgentTimer: Bool {
        viewModel.timeRemaining <= 5.0 && viewModel.timeRemaining > 0
    }
    
    private var timerBarColor: Color {
        if isUrgentTimer {
            return .red
        } else if viewModel.timeRemaining <= 8.0 {
            return .orange
        } else {
            return .green
        }
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            // Top HUD Banner
            topHeaderBar
            
            // Question Prompt Card
            questionPromptSection
            
            // Live Countdown Timer Track
            countdownTimerSection
            
            // 2x2 Grid of 4 Multiple-Choice Cards
            answerCardsGrid
            
            // Bottom Locked-in Players Status
            bottomLockedStatus
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 24)
    }
    
    // MARK: - Sub-expressions
    
    @ViewBuilder
    private var topHeaderBar: some View {
        HStack {
            // Category Badge
            HStack(spacing: 8) {
                Image(systemName: viewModel.selectedCategory.type.icon)
                    .font(.system(size: 15, weight: .bold))
                Text(viewModel.selectedCategory.type.rawValue.uppercased())
                    .font(.system(size: 12, weight: .black, design: .rounded))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.12))
            .foregroundColor(.white)
            .clipShape(Capsule())
            
            Spacer()
            
            // Question Number Counter
            Text("QUESTION \(viewModel.currentRoundNumber) OF \(viewModel.totalQuestionsInPack)")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(.cyan)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.cyan.opacity(0.15))
                .clipShape(Capsule())
            
            Spacer()
            
            // Base Points
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("\(viewModel.currentQuestion.basePoints) PTS + SPEED BONUS")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
        }
    }
    
    @ViewBuilder
    private var questionPromptSection: some View {
        VStack(spacing: 8) {
            Text(viewModel.currentQuestion.prompt)
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity, minHeight: 120)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var countdownTimerSection: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 12)
                    
                    // Active fill
                    Capsule()
                        .fill(timerBarColor)
                        .frame(width: max(0, geo.size.width * CGFloat(viewModel.timerProgress)), height: 12)
                        .animation(.linear(duration: 0.1), value: viewModel.timeRemaining)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text(isUrgentTimer ? "HURRY! FASTEST ANSWER WINS BONUS!" : "TIME REMAINING")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(isUrgentTimer ? .red : .white.opacity(0.5))
                
                Spacer()
                
                Text(String(format: "%.1fs", viewModel.timeRemaining))
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .foregroundColor(isUrgentTimer ? .red : .white)
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var answerCardsGrid: some View {
        let question = viewModel.currentQuestion
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 24), GridItem(.flexible(), spacing: 24)], spacing: 20) {
            ForEach(0..<question.options.count, id: \.self) { index in
                Button(action: {
                    // Siri Remote Host Player locks in answer on click
                    viewModel.lockInAnswer(playerId: "player-remote", answerIndex: index)
                }) {
                    HStack(spacing: 20) {
                        // Letter Pill
                        ZStack {
                            Circle()
                                .fill(optionColors[index % optionColors.count])
                                .frame(width: 48, height: 48)
                            
                            Text(optionLetters[index % optionLetters.count])
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Text(question.options[index])
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        // Player avatars who locked in on this choice
                        let lockedPlayers = viewModel.players.filter { $0.isLockedIn && $0.selectedAnswerIndex == index }
                        HStack(spacing: -8) {
                            ForEach(lockedPlayers) { p in
                                Circle()
                                    .fill(Color(hex: p.colorHex))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: p.avatarIcon)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.black)
                                    )
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: 2)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                focusedAnswerIndex == index ? optionColors[index % optionColors.count] : Color.white.opacity(0.12),
                                lineWidth: focusedAnswerIndex == index ? 4 : 1.5
                            )
                    )
                }
                .buttonStyle(.card)
                .focused($focusedAnswerIndex, equals: index)
            }
        }
    }
    
    @ViewBuilder
    private var bottomLockedStatus: some View {
        HStack(spacing: 16) {
            let lockedCount = viewModel.players.filter { $0.isLockedIn }.count
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.cyan)
                Text("\(lockedCount) OF \(viewModel.players.count) PLAYERS LOCKED IN")
                    .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
            
            Spacer()
            
            // Quick Simulation button for solo testing / remote click
            Button(action: {
                // Simulate companion phone buzzers locking in
                let mockChoices = [0, 1, 2, 3].shuffled()
                if let sarah = viewModel.players.first(where: { $0.id == "player-sarah" && !$0.isLockedIn }) {
                    viewModel.lockInAnswer(playerId: sarah.id, answerIndex: mockChoices[0])
                }
                if let dave = viewModel.players.first(where: { $0.id == "player-dave" && !$0.isLockedIn }) {
                    viewModel.lockInAnswer(playerId: dave.id, answerIndex: mockChoices[1])
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "iphone.badge.play")
                    Text("Simulate iPhone Buzzers")
                }
                .font(.system(size: 13, weight: .bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .foregroundColor(.cyan)
                .clipShape(Capsule())
            }
            .buttonStyle(.card)
        }
    }
}
