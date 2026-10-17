import SwiftUI

public struct TVRootConductorView: View {
    @StateObject private var viewModel = TVConductorViewModel()
    @FocusState private var focusedControl: String?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Ambient Culinary Backdrop with dynamic glow
            RadialGradient(
                colors: [
                    Color(hex: "#1e1b18"),
                    Color(hex: "#100e0d"),
                    Color(hex: "#080706")
                ],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 1200
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // MARK: - Top 10-Foot Header Bar
                HStack(alignment: .center, spacing: 20) {
                    // Brand & Dish Title
                    HStack(spacing: 16) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 8) {
                                Text("KITCHENCREW")
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundColor(.orange)
                                    .tracking(2)
                                
                                Text("•")
                                    .foregroundColor(.white.opacity(0.4))
                                
                                Text(viewModel.recipe.masterChef)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Text(viewModel.recipe.title)
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    // Voice Conductor Waveform
                    VoiceWaveformOverlayView(viewModel: viewModel)
                        .onTapGesture {
                            viewModel.toggleVoiceConductor()
                        }
                    
                    // Connected Crew Pill
                    HStack(spacing: 8) {
                        Image(systemName: "person.2.wave.2.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.cyan)
                        Text("\(viewModel.connectedChefs.count) CHEFS SYNCED")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 48)
                .padding(.top, 24)
                
                // Overall Master Recipe Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(viewModel.currentProgress), height: 6)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 48)
                
                // MARK: - Middle Main Workstation (Left Video / Right Step Instructions)
                HStack(alignment: .top, spacing: 32) {
                    // Left 60%: Multi-Angle Video Player & Camera Switcher
                    VStack(alignment: .leading, spacing: 16) {
                        MultiAngleVideoPlayerView(viewModel: viewModel)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Right 40%: Current Master Step Card (10-Foot Readability)
                    VStack(alignment: .leading, spacing: 20) {
                        // Step Header Badges
                        HStack {
                            Text("STEP \(viewModel.currentStepIndex + 1) OF \(viewModel.recipe.steps.count)")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.orange.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            
                            Spacer()
                            
                            // Station Assignment Tag
                            HStack(spacing: 6) {
                                Image(systemName: viewModel.currentStep.assignedStation.icon)
                                    .font(.system(size: 14, weight: .bold))
                                Text(viewModel.currentStep.assignedStation.rawValue.uppercased())
                                    .font(.system(size: 12, weight: .black))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Color(hex: viewModel.currentStep.assignedStation.colorHex).opacity(0.2))
                            .foregroundColor(Color(hex: viewModel.currentStep.assignedStation.colorHex))
                            .clipShape(Capsule())
                        }
                        
                        // Step Title
                        Text(viewModel.currentStep.title)
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        // Step Instruction (Oversized for kitchen visibility)
                        Text(viewModel.currentStep.instruction)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Chef Tip / Critical Callout
                        if let warning = viewModel.currentStep.criticalWarning {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.yellow)
                                Text(warning)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.yellow.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
                            )
                        } else if let tip = viewModel.currentStep.chefTip {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.orange)
                                Text("CHEF TIP: \(tip)")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        
                        Spacer()
                        
                        // Focusable Step Controls (tvOS remote gestures)
                        HStack(spacing: 16) {
                            Button(action: {
                                viewModel.previousStep()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .font(.system(size: 18, weight: .bold))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .buttonStyle(.card)
                            .disabled(viewModel.currentStepIndex == 0)
                            
                            Button(action: {
                                viewModel.nextStep()
                            }) {
                                HStack(spacing: 8) {
                                    Text(viewModel.currentStepIndex == viewModel.recipe.steps.count - 1 ? "Complete Recipe 🎉" : "Step Complete (Next)")
                                    Image(systemName: "checkmark.circle.fill")
                                }
                                .font(.system(size: 20, weight: .heavy))
                                .padding(.horizontal, 28)
                                .padding(.vertical, 16)
                                .background(Color.orange)
                                .foregroundColor(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            .buttonStyle(.card)
                            
                            Button(action: {
                                viewModel.isQuickActionPresented = true
                            }) {
                                Image(systemName: "ellipsis.circle.fill")
                                    .font(.system(size: 26))
                                    .padding(14)
                                    .background(Color.white.opacity(0.1))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.card)
                        }
                    }
                    .padding(28)
                    .frame(width: 480)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 48)
                
                // MARK: - Bottom Bar (Sub-Station Status + Oversized 10-Foot Timers)
                HStack(alignment: .center, spacing: 32) {
                    // Left: Sub-Station Status Strip
                    CrewStationStatusStripView(chefs: viewModel.connectedChefs)
                    
                    Spacer()
                    
                    // Right: Oversized Countdown Timers
                    HStack(spacing: 16) {
                        ForEach(viewModel.activeTimers) { timer in
                            BigScreenTimerView(timer: timer) {
                                viewModel.startOrPauseTimer(id: timer.id)
                            }
                        }
                    }
                }
                .padding(.horizontal, 48)
                .padding(.bottom, 28)
            }
            
            // MARK: - Floating Real-time Toast Notifications
            if let toast = viewModel.activeToastMessage {
                VStack {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(viewModel.activeToastColor)
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
                            .stroke(viewModel.activeToastColor.opacity(0.6), lineWidth: 1.5)
                    )
                    .shadow(color: viewModel.activeToastColor.opacity(0.4), radius: 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 40)
                    
                    Spacer()
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.activeToastMessage)
            }
            
            // MARK: - Quick Action / Substitutions Modal
            if viewModel.isQuickActionPresented {
                QuickActionModalView(viewModel: viewModel)
                    .transition(.opacity)
            }
        }
    }
}
