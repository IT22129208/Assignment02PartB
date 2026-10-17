import SwiftUI

public struct LobbyView: View {
    @ObservedObject var viewModel: TVTriviaGameViewModel
    @FocusState private var focusedButton: String?
    
    public init(viewModel: TVTriviaGameViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 36) {
            // Header Section
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    TriviaLogoBadge(size: 68)
                    
                    Text("TRIVIANIGHT TV")
                        .font(.system(size: 46, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(3)
                }
                
                Text("THE LIVING ROOM PUB QUIZ • MULTI-USER TVOS EXPERIENCE")
                    .font(.system(size: 16, weight: .heavy, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(2)
            }
            .padding(.top, 24)
            
            // Middle: Room Code + Connected Players
            HStack(alignment: .top, spacing: 40) {
                // Left Panel: Living Room Room Code
                VStack(spacing: 20) {
                    Text("LOCAL ROOM CODE")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.cyan)
                        .tracking(2)
                    
                    Text("PUB-4K")
                        .font(.system(size: 64, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.cyan.opacity(0.5), lineWidth: 2)
                        )
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(.cyan)
                            Text("Open TriviaNight Companion on iPhone")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Text("Or use this Apple TV Siri Remote to play directly")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(32)
                .frame(width: 440)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                // Right Panel: Connected Living Room Players Grid
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("PLAYERS IN ROOM (\(viewModel.players.count))")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("MIN 1 • MAX 8 PLAYERS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.players) { player in
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: player.colorHex))
                                        .frame(width: 52, height: 52)
                                    
                                    Image(systemName: player.avatarIcon)
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(player.name)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 8, height: 8)
                                        Text(player.controllerType.rawValue)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        
                        if viewModel.players.count == 1 {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .strokeBorder(Color.cyan.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                                        .frame(width: 52, height: 52)
                                    
                                    Image(systemName: "iphone.radiowaves.left.and.right")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.cyan)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Waiting for iPhone...")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("Type your name in the mobile app")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.cyan.opacity(0.8))
                                }
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(Color.cyan.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 48)
            
            Spacer()
            
            // Bottom Action Controls
            HStack(spacing: 24) {
                Button(action: {
                    viewModel.navigateToCategorySelect()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "square.grid.2x2.fill")
                        Text("Category Packs")
                    }
                    .font(.system(size: 20, weight: .bold))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.12))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.card)
                .focused($focusedButton, equals: "categories")
                
                Button(action: {
                    viewModel.startTriviaRound()
                }) {
                    HStack(spacing: 12) {
                        Text("Start Trivia Night")
                        Image(systemName: "play.circle.fill")
                    }
                    .font(.system(size: 22, weight: .heavy))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.card)
                .focused($focusedButton, equals: "start")
            }
            .padding(.bottom, 40)
        }
    }
}

fileprivate struct TriviaLogoBadge: View {
    let size: CGFloat
    
    init(size: CGFloat = 68) {
        self.size = size
    }
    
    var body: some View {
        if let uiImage = loadLogoImage() {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.26, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.8), Color.cyan.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: max(1, size * 0.03)
                        )
                )
                .shadow(color: Color.orange.opacity(0.4), radius: size * 0.2, x: 0, y: 0)
        } else {
            fallbackLogoView
        }
    }
    
    @ViewBuilder
    private var fallbackLogoView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#1e1b4b"), Color(hex: "#09090b")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.yellow, Color.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: max(1.5, size * 0.04)
                        )
                )
                .shadow(color: Color.cyan.opacity(0.4), radius: size * 0.2)
            
            HStack(spacing: size * 0.05) {
                Image(systemName: "mug.fill")
                    .font(.system(size: size * 0.38, weight: .bold))
                    .foregroundColor(.yellow)
                
                Image(systemName: "questionmark")
                    .font(.system(size: size * 0.42, weight: .black))
                    .foregroundColor(.cyan)
            }
        }
    }
    
    private func loadLogoImage() -> UIImage? {
        if let path = Bundle.main.path(forResource: "logo", ofType: "jpg"),
           let img = UIImage(contentsOfFile: path) {
            return img
        }
        return nil
    }
}

