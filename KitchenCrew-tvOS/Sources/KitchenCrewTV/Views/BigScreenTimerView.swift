import SwiftUI

public struct BigScreenTimerView: View {
    let timer: KitchenTimer
    let onToggle: () -> Void
    
    @State private var isPulsing: Bool = false
    
    public init(timer: KitchenTimer, onToggle: @escaping () -> Void) {
        self.timer = timer
        self.onToggle = onToggle
    }
    
    private var isUrgent: Bool {
        timer.remainingSeconds <= 30 && timer.remainingSeconds > 0
    }
    
    public var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 20) {
                // Circular Progress Dial
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(timer.progress))
                        .stroke(
                            isUrgent ? Color.red : (timer.associatedStation?.colorHex.map { Color(hex: $0) } ?? Color.orange),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 80, height: 80)
                        .animation(.linear(duration: 1.0), value: timer.remainingSeconds)
                    
                    Image(systemName: timer.isRunning ? "timer" : "pause.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(isUrgent ? .red : .white)
                }
                
                // Huge Digits & Label (10-Foot legibility)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(timer.label.uppercased())
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                        
                        if let station = timer.associatedStation {
                            Text(station.rawValue)
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(hex: station.colorHex).opacity(0.25))
                                .foregroundColor(Color(hex: station.colorHex))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(timer.formattedTime)
                        .font(.system(size: 44, weight: .black, design: .monospaced))
                        .foregroundColor(isUrgent ? .red : .white)
                        .shadow(color: isUrgent ? .red.opacity(0.8) : .clear, radius: 10)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isUrgent ? Color.red.opacity(0.15) : Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(isUrgent ? Color.red : Color.white.opacity(0.15), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.card)
        .scaleEffect(isUrgent && isPulsing ? 1.03 : 1.0)
        .onAppear {
            if isUrgent {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
        }
    }
}

// Color hex helper for SwiftUI
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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
