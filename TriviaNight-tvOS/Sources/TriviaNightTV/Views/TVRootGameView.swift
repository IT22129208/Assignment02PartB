import SwiftUI

public struct TVRootGameView: View {
    @StateObject private var viewModel = TVTriviaGameViewModel()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Ambient Living Room Pub Backdrop
            RadialGradient(
                colors: [
                    Color(hex: "#1e1b2e"), // Deep Indigo Pub Ambient
                    Color(hex: "#110e1c"),
                    Color(hex: "#09070f")
                ],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 1200
            )
            .ignoresSafeArea()
            
            // Screen Transitions Based on GameState
            Group {
                switch viewModel.gameState {
                case .lobby:
                    LobbyView(viewModel: viewModel)
                case .categorySelect:
                    CategorySelectView(viewModel: viewModel)
                case .questionCountdown(let count):
                    countdownSplash(count: count)
                case .questionActive:
                    QuestionTimerBoardView(viewModel: viewModel)
                case .answerReveal:
                    AnswerRevealView(viewModel: viewModel)
                case .roundScoreboard:
                    RoundScoreboardView(viewModel: viewModel)
                case .finalPodium:
                    WinnerCelebrationView(viewModel: viewModel)
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
            
            // Floating Toast Alert
            if let toast = viewModel.activeToastMessage {
                VStack {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: viewModel.activeToastColorHex))
                            .frame(width: 12, height: 12)
                        
                        Text(toast)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: viewModel.activeToastColorHex).opacity(0.6), lineWidth: 1.5)
                    )
                    .shadow(color: Color(hex: viewModel.activeToastColorHex).opacity(0.4), radius: 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 40)
                    
                    Spacer()
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.activeToastMessage)
            }
        }
    }
    
    @ViewBuilder
    private func countdownSplash(count: Int) -> some View {
        VStack(spacing: 20) {
            Text("ROUND \(viewModel.currentRoundNumber)")
                .font(.system(size: 20, weight: .black, design: .monospaced))
                .foregroundColor(.cyan)
                .tracking(3)
            
            Text("\(count)")
                .font(.system(size: 140, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .scaleEffect(1.2)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: count)
            
            Text("GET READY TO BUZZ IN!")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.yellow)
                .tracking(2)
        }
    }
}
