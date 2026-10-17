import SwiftUI

public struct RoundScoreboardView: View {
    @ObservedObject var viewModel: TVTriviaGameViewModel
    @FocusState private var isFocused: Bool
    
    public init(viewModel: TVTriviaGameViewModel) {
        self.viewModel = viewModel
    }
    
    private var isLastQuestion: Bool {
        viewModel.currentQuestionIndex >= viewModel.totalQuestionsInPack - 1
    }
    
    public var body: some View {
        VStack(spacing: 28) {
            // Header
            VStack(spacing: 6) {
                Text("ROUND \(viewModel.currentRoundNumber) OF \(viewModel.totalQuestionsInPack) COMPLETE")
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundColor(.yellow)
                    .tracking(2)
                
                Text("Current Leaderboard")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.top, 24)
            
            // Leaderboard Ranked Cards
            VStack(spacing: 14) {
                ForEach(Array(viewModel.rankedPlayers.enumerated()), id: \.element.id) { index, player in
                    HStack(spacing: 20) {
                        // Rank Numeral Pill
                        ZStack {
                            Circle()
                                .fill(rankColor(for: index))
                                .frame(width: 44, height: 44)
                            
                            Text("#\(index + 1)")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                        }
                        
                        // Player Avatar & Name
                        ZStack {
                            Circle()
                                .fill(Color(hex: player.colorHex))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: player.avatarIcon)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(player.name)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 10) {
                                Text("\(player.correctAnswersCount)/\(player.totalAnswersCount) Correct")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                if player.streak > 1 {
                                    Text("🔥 \(player.streak) streak")
                                        .font(.system(size: 12, weight: .heavy))
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Total Score
                        Text("\(player.score) PTS")
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(index == 0 ? 0.12 : 0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(index == 0 ? Color.yellow.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1.5)
                    )
                }
            }
            .padding(.horizontal, 48)
            .frame(maxWidth: 880)
            
            Spacer()
            
            // Next Question or Final Ceremony Button
            Button(action: {
                viewModel.nextRoundOrFinish()
            }) {
                HStack(spacing: 10) {
                    Text(isLastQuestion ? "View Final Pub Champions 🎉" : "Next Question")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 22, weight: .heavy))
                .padding(.horizontal, 36)
                .padding(.vertical, 16)
                .background(Color.orange)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.card)
            .focused($isFocused)
            .padding(.bottom, 32)
        }
    }
    
    private func rankColor(for index: Int) -> Color {
        switch index {
        case 0: return .yellow   // Gold
        case 1: return Color(white: 0.8) // Silver
        case 2: return Color(hex: "#cd7f32") // Bronze
        default: return Color.white.opacity(0.4)
        }
    }
}
