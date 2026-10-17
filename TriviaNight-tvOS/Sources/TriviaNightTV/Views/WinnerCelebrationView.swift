import SwiftUI

public struct WinnerCelebrationView: View {
    @ObservedObject var viewModel: TVTriviaGameViewModel
    @FocusState private var focusedAction: String?
    @State private var confettiOffset: CGFloat = 0
    
    public init(viewModel: TVTriviaGameViewModel) {
        self.viewModel = viewModel
    }
    
    private var winner: Player? {
        viewModel.rankedPlayers.first
    }
    
    private var runnerUp: Player? {
        viewModel.rankedPlayers.count > 1 ? viewModel.rankedPlayers[1] : nil
    }
    
    private var thirdPlace: Player? {
        viewModel.rankedPlayers.count > 2 ? viewModel.rankedPlayers[2] : nil
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 6) {
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.yellow)
                    Text("PUB QUIZ CHAMPIONS")
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                        .tracking(3)
                }
                
                Text(winner?.name ?? "Trivia Champion")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.top, 24)
            
            // 3-Step Podium Pedestal View
            podiumSection
            
            // MVP Highlights Strip
            mvpHighlightsSection
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 24) {
                Button(action: {
                    viewModel.restartToLobby()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Play Again")
                    }
                    .font(.system(size: 20, weight: .bold))
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.12))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.card)
                .focused($focusedAction, equals: "again")
                
                Button(action: {
                    viewModel.navigateToCategorySelect()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "square.grid.2x2.fill")
                        Text("New Category Pack")
                    }
                    .font(.system(size: 22, weight: .heavy))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.card)
                .focused($focusedAction, equals: "category")
            }
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Podium Subview
    
    @ViewBuilder
    private var podiumSection: some View {
        HStack(alignment: .bottom, spacing: 20) {
            // 2nd Place (Silver)
            if let p2 = runnerUp {
                podiumColumn(player: p2, rank: 2, height: 160, color: Color(white: 0.8))
            }
            
            // 1st Place (Gold)
            if let p1 = winner {
                podiumColumn(player: p1, rank: 1, height: 230, color: .yellow)
            }
            
            // 3rd Place (Bronze)
            if let p3 = thirdPlace {
                podiumColumn(player: p3, rank: 3, height: 120, color: Color(hex: "#cd7f32"))
            }
        }
        .frame(maxWidth: 720)
    }
    
    @ViewBuilder
    private func podiumColumn(player: Player, rank: Int, height: CGFloat, color: Color) -> some View {
        VStack(spacing: 10) {
            // Avatar & Name
            ZStack {
                Circle()
                    .fill(Color(hex: player.colorHex))
                    .frame(width: rank == 1 ? 72 : 56, height: rank == 1 ? 72 : 56)
                
                Image(systemName: player.avatarIcon)
                    .font(.system(size: rank == 1 ? 30 : 22, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Text(player.name)
                .font(.system(size: rank == 1 ? 22 : 18, weight: .bold))
                .foregroundColor(.white)
            
            Text("\(player.score) PTS")
                .font(.system(size: rank == 1 ? 20 : 16, weight: .black, design: .monospaced))
                .foregroundColor(color)
            
            // Pedestal Block
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color.opacity(0.2))
                    .frame(height: height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(color.opacity(0.6), lineWidth: 2)
                    )
                
                Text("#\(rank)")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(color)
                    .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - MVP Awards Strip
    
    @ViewBuilder
    private var mvpHighlightsSection: some View {
        HStack(spacing: 24) {
            // Highest Streak
            if let streakMVP = viewModel.players.max(by: { $0.highestStreak < $1.highestStreak }) {
                mvpBadge(
                    title: "LONGEST STREAK",
                    playerName: streakMVP.name,
                    value: "🔥 \(streakMVP.highestStreak) In A Row",
                    accentColor: .orange
                )
            }
            
            // Accuracy Master
            if let accuracyMVP = viewModel.players.max(by: { $0.accuracyPercentage < $1.accuracyPercentage }) {
                mvpBadge(
                    title: "ACCURACY ACE",
                    playerName: accuracyMVP.name,
                    value: "\(Int(accuracyMVP.accuracyPercentage))% Correct",
                    accentColor: .green
                )
            }
        }
        .padding(.horizontal, 48)
    }
    
    @ViewBuilder
    private func mvpBadge(title: String, playerName: String, value: String, accentColor: Color) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(accentColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "award.fill")
                        .foregroundColor(accentColor)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(accentColor)
                    .tracking(1)
                Text("\(playerName) • \(value)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.06))
        .clipShape(Capsule())
    }
}
