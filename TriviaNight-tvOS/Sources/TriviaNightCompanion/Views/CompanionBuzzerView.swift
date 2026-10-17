import SwiftUI

public struct CompanionBuzzerView: View {
    @StateObject private var viewModel = CompanionBuzzerViewModel()
    @State private var localName: String = ""
    @State private var localAvatar: String = "sparkles"
    @State private var localColorHex: String = "#f43f5e"
    
    private let choices = [
        ("A", "#f43f5e"), // Rose
        ("B", "#0ea5e9"), // Sky
        ("C", "#eab308"), // Amber
        ("D", "#a855f7")  // Violet
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header Connection Banner
                connectionHeader
                
                if !viewModel.hasJoined {
                    // Profile & Name Entry Screen
                    joinProfileForm
                } else {
                    // Active Buzzer Screen
                    activeBuzzerView
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("TriviaNight Mobile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if localName.isEmpty && !viewModel.playerName.isEmpty {
                    localName = viewModel.playerName
                }
            }
            .onChange(of: localName) { newName in
                viewModel.updateLiveNameDraft(name: newName, avatar: localAvatar, colorHex: localColorHex)
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var connectionHeader: some View {
        HStack {
            HStack(spacing: 8) {
                TriviaLogoBadge(size: 22)
                
                Circle()
                    .fill(viewModel.isConnectedToTV ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                
                Text(viewModel.isConnectedToTV ? "Connected to Apple TV 4K" : "Searching...")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("ROOM: \(viewModel.roomCode)")
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.12))
                .foregroundColor(.cyan)
                .clipShape(Capsule())
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
    @ViewBuilder
    private var joinProfileForm: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                TriviaLogoBadge(size: 64)
                
                Text("Join Trivia Night")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Enter your name to appear on the living room TV screen")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 4)
            
            // Name Input Field
            VStack(alignment: .leading, spacing: 8) {
                Text("PLAYER NICKNAME")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundColor(.cyan)
                
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.white.opacity(0.5))
                    
                    TextField("Enter your name (e.g. Alex)", text: $localName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .autocorrectionDisabled()
                    
                    if !localName.isEmpty {
                        Button(action: { localName = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                }
                .padding(14)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            
            // Avatar Selector
            VStack(alignment: .leading, spacing: 8) {
                Text("CHOOSE AVATAR")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundColor(.yellow)
                
                HStack(spacing: 12) {
                    ForEach(viewModel.availableAvatars, id: \.self) { avatar in
                        Button(action: {
                            localAvatar = avatar
                        }) {
                            ZStack {
                                Circle()
                                    .fill(localAvatar == avatar ? Color(hex: localColorHex) : Color.white.opacity(0.08))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: avatar)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(localAvatar == avatar ? .black : .white)
                            }
                            .overlay(
                                Circle()
                                    .stroke(localAvatar == avatar ? Color.white : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Color Selector
            VStack(alignment: .leading, spacing: 8) {
                Text("BUZZER COLOR")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundColor(.orange)
                
                HStack(spacing: 12) {
                    ForEach(viewModel.availableColors, id: \.self) { colorHex in
                        Button(action: {
                            localColorHex = colorHex
                        }) {
                            Circle()
                                .fill(Color(hex: colorHex))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(localColorHex == colorHex ? Color.white : Color.clear, lineWidth: 3)
                                )
                                .scaleEffect(localColorHex == colorHex ? 1.15 : 1.0)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Join Button
            Button(action: {
                let nameToUse = localName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Guest Player" : localName
                viewModel.joinRoom(name: nameToUse, avatar: localAvatar, colorHex: localColorHex)
            }) {
                HStack(spacing: 10) {
                    Text("Join Game on TV 🚀")
                    Image(systemName: "tv.fill")
                }
                .font(.system(size: 18, weight: .heavy))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
    
    @ViewBuilder
    private var activeBuzzerView: some View {
        VStack(spacing: 20) {
            // Player Status Pill with Edit Button
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: viewModel.selectedColorHex))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: viewModel.selectedAvatar)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.playerName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(viewModel.isLockedIn ? "Answer Locked In!" : "Look at TV and buzz in!")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(viewModel.isLockedIn ? .green : .white.opacity(0.6))
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.editProfile()
                }) {
                    Text("Edit Name")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.12))
                        .foregroundColor(.white.opacity(0.8))
                        .clipShape(Capsule())
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal)
            
            // 4 Large Quadrant Buzzer Buttons
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach(0..<choices.count, id: \.self) { idx in
                    let item = choices[idx]
                    let isSelected = viewModel.selectedAnswerIndex == idx
                    
                    Button(action: {
                        viewModel.selectAnswer(index: idx)
                    }) {
                        VStack(spacing: 8) {
                            Text(item.0)
                                .font(.system(size: 54, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            
                            if isSelected {
                                Text("LOCKED")
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Capsule())
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(hex: item.1).opacity(viewModel.isLockedIn && !isSelected ? 0.25 : 0.85))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
                                )
                        )
                    }
                    .disabled(viewModel.isLockedIn)
                    .aspectRatio(1.0, contentMode: .fit)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

fileprivate extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
