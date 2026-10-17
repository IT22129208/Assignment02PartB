import SwiftUI

public struct AnswerRevealView: View {
    @ObservedObject var viewModel: TVTriviaGameViewModel
    @FocusState private var isFocused: Bool
    
    public init(viewModel: TVTriviaGameViewModel) {
        self.viewModel = viewModel
    }
    
    private var correctOption: String {
        let q = viewModel.currentQuestion
        guard q.correctIndex >= 0 && q.correctIndex < q.options.count else { return "" }
        return q.options[q.correctIndex]
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            // Header
            Text("ROUND RESULTS")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(.green)
                .tracking(2)
                .padding(.top, 16)
            
            // Correct Answer Reveal Banner
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("CORRECT ANSWER:")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Text(correctOption)
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(Color.green.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.green.opacity(0.5), lineWidth: 2)
            )
            .padding(.horizontal, 48)
            
            // Pub Trivia Trivia Fact / Explanation
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("TRIVIA CURIO")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.yellow)
                        .tracking(1)
                    
                    Text(viewModel.currentQuestion.explanation)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(4)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(.horizontal, 48)
            
            // Players Round Breakdown
            VStack(alignment: .leading, spacing: 12) {
                Text("ROUND SCORING & SPEED")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 48)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(viewModel.players) { player in
                        let isCorrect = player.selectedAnswerIndex == viewModel.currentQuestion.correctIndex
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: player.colorHex))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: player.avatarIcon)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(player.name)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 6) {
                                    if let time = player.answerTimeSeconds {
                                        Text("\(String(format: "%.1f", time))s")
                                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    
                                    if player.streak > 1 {
                                        Text("🔥 \(player.streak)x Streak")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            if isCorrect {
                                Text("+\(player.pointsAwardedLastRound)")
                                    .font(.system(size: 20, weight: .black, design: .monospaced))
                                    .foregroundColor(.green)
                            } else {
                                Text("0")
                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                                    .foregroundColor(.red.opacity(0.7))
                            }
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(isCorrect ? Color.green.opacity(0.4) : Color.red.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 48)
            }
            
            Spacer()
            
            // Continue Button
            Button(action: {
                viewModel.proceedFromAnswerReveal()
            }) {
                HStack(spacing: 10) {
                    Text("View Standings")
                    Image(systemName: "trophy.fill")
                }
                .font(.system(size: 20, weight: .heavy))
                .padding(.horizontal, 36)
                .padding(.vertical, 16)
                .background(Color.white)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.card)
            .focused($isFocused)
            .padding(.bottom, 24)
        }
    }
}
