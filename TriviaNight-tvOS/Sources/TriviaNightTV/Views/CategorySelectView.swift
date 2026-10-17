import SwiftUI

public struct CategorySelectView: View {
    @ObservedObject var viewModel: TVTriviaGameViewModel
    @FocusState private var focusedCategory: TriviaCategoryType?
    
    public init(viewModel: TVTriviaGameViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 28) {
            // Header
            HStack {
                Button(action: {
                    viewModel.restartToLobby()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Lobby")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(.card)
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("CHOOSE YOUR TRIVIA PACK")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(.cyan)
                        .tracking(2)
                    
                    Text("Select Tonight's Theme")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(viewModel.categories.count) PACKS AVAILABLE")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 48)
            .padding(.top, 24)
            
            // 2x2 or 2x3 Grid of Categories
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                ForEach(viewModel.categories) { category in
                    Button(action: {
                        viewModel.selectCategory(category)
                    }) {
                        HStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: category.type.colorStartHex), Color(hex: category.type.colorEndHex)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 76, height: 76)
                                
                                Image(systemName: category.type.icon)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(category.type.rawValue)
                                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(category.questions.count) Questions")
                                        .font(.system(size: 12, weight: .black, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.3))
                                        .clipShape(Capsule())
                                }
                                
                                Text(category.type.tagline)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(24)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: category.type.colorStartHex).opacity(0.25),
                                    Color(hex: category.type.colorEndHex).opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(
                                    focusedCategory == category.type ? Color.white : Color.white.opacity(0.15),
                                    lineWidth: focusedCategory == category.type ? 3 : 1
                                )
                        )
                    }
                    .buttonStyle(.card)
                    .focused($focusedCategory, equals: category.type)
                }
            }
            .padding(.horizontal, 48)
            
            Spacer()
        }
    }
}
