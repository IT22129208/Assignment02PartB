import SwiftUI

public struct TriviaLogoBadge: View {
    public let size: CGFloat
    
    public init(size: CGFloat = 64) {
        self.size = size
    }
    
    public var body: some View {
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
        // Try Bundle.main
        if let path = Bundle.main.path(forResource: "logo", ofType: "jpg"),
           let img = UIImage(contentsOfFile: path) {
            return img
        }
        // Try Bundle.module if available
        #if SWIFT_PACKAGE
        if let url = Bundle.module.url(forResource: "logo", withExtension: "jpg"),
           let data = try? Data(contentsOf: url),
           let img = UIImage(data: data) {
            return img
        }
        #endif
        return nil
    }
}
