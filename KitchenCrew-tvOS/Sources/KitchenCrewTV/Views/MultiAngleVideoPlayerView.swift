import SwiftUI
import AVKit

public struct MultiAngleVideoPlayerView: View {
    @ObservedObject var viewModel: TVConductorViewModel
    @FocusState private var focusedAngle: CameraAngle?
    @Namespace private var animation
    
    public init(viewModel: TVConductorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Main Video Display Area
            ZStack(alignment: .bottomLeading) {
                // Video Backdrop simulation / Video layer
                GeometryReader { geo in
                    ZStack {
                        if viewModel.isSplitScreen {
                            HStack(spacing: 4) {
                                // Angle 1: Wide Chef
                                VideoFeedCard(
                                    angle: .wideChef,
                                    label: "CHEF STATION (WIDE)",
                                    assetName: "chef_wide",
                                    isActive: true,
                                    width: geo.size.width / 2 - 2,
                                    height: geo.size.height
                                )
                                // Angle 2: Macro Sizzle
                                VideoFeedCard(
                                    angle: .macroPan,
                                    label: "PAN SIZZLE (MACRO)",
                                    assetName: "pan_macro",
                                    isActive: true,
                                    width: geo.size.width / 2 - 2,
                                    height: geo.size.height
                                )
                            }
                        } else {
                            // Single Angle with Smooth Transition
                            VideoFeedCard(
                                angle: viewModel.activeCameraAngle,
                                label: viewModel.activeCameraAngle.rawValue.uppercased(),
                                assetName: viewModel.activeCameraAngle == .macroPan ? "pan_macro" : "chef_wide",
                                isActive: true,
                                width: geo.size.width,
                                height: geo.size.height
                            )
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.6), radius: 24, x: 0, y: 12)
                }
                .aspectRatio(16/9, contentMode: .fit)
                
                // Stream Overlays (LIVE badge, audio sync tag)
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                        Text("4K MULTI-CAM LIVE")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    
                    Text("HLS FRAME-SYNCED (0.02s)")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Capsule())
                }
                .padding(20)
            }
            
            // Camera Angle Switcher (tvOS Focusable Row)
            HStack(spacing: 20) {
                ForEach(CameraAngle.allCases) { angle in
                    Button(action: {
                        viewModel.setCameraAngle(angle)
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: angle.iconName)
                                .font(.system(size: 20, weight: .semibold))
                            Text(angle.rawValue)
                                .font(.system(size: 18, weight: .bold))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            viewModel.activeCameraAngle == angle && !viewModel.isSplitScreen
                                ? Color.orange
                                : Color.white.opacity(0.12)
                        )
                        .foregroundColor(
                            viewModel.activeCameraAngle == angle && !viewModel.isSplitScreen
                                ? .black
                                : .white
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.card)
                    .focused($focusedAngle, equals: angle)
                }
                
                // Split-Screen Toggle Button
                Button(action: {
                    viewModel.toggleSplitScreen()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.split.2x1.fill")
                            .font(.system(size: 20))
                        Text(viewModel.isSplitScreen ? "Single Cam" : "Split Dual-Cam")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(viewModel.isSplitScreen ? Color.cyan : Color.white.opacity(0.12))
                    .foregroundColor(viewModel.isSplitScreen ? .black : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.card)
            }
        }
    }
}

private struct VideoFeedCard: View {
    let angle: CameraAngle
    let label: String
    let assetName: String
    let isActive: Bool
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Simulated video asset image with cinematic gradient
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.7)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
            
            // Angle Label Tag
            Text(label)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.6))
                .clipShape(Capsule())
                .padding(14)
        }
        .frame(width: width, height: height)
    }
}
