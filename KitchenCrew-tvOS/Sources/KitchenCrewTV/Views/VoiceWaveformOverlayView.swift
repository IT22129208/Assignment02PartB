import SwiftUI

public struct VoiceWaveformOverlayView: View {
    @ObservedObject var viewModel: TVConductorViewModel
    @State private var wavePhase: CGFloat = 0
    
    public init(viewModel: TVConductorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            // Glowing Siri/Microphone Orb
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.cyan, Color.purple, Color.clear],
                            center: .center,
                            startRadius: 2,
                            endRadius: 24
                        )
                    )
                    .frame(width: 44, height: 44)
                    .scaleEffect(viewModel.isVoiceActive ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.isVoiceActive)
                
                Image(systemName: "mic.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Audio Bars
            HStack(spacing: 4) {
                ForEach(0..<6) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(colors: [.cyan, .purple], startPoint: .top, endPoint: .bottom))
                        .frame(width: 4, height: viewModel.isVoiceActive ? CGFloat.random(in: 12...32) : 8)
                        .animation(.easeInOut(duration: 0.25).repeatForever().delay(Double(index) * 0.05), value: viewModel.isVoiceActive)
                }
            }
            
            // Live Kitchen Transcript
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.isVoiceActive ? "VOICE RECOGNITION ACTIVE" : "HANDS-FREE KITCHEN CONDUCE")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.cyan)
                
                Text(viewModel.lastVoiceQuery)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(colors: [.cyan.opacity(0.6), .purple.opacity(0.6)], startPoint: .leading, endPoint: .trailing),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.cyan.opacity(0.3), radius: 12)
    }
}
