import SwiftUI

public struct QuickActionModalView: View {
    @ObservedObject var viewModel: TVConductorViewModel
    @FocusState private var focusedItem: String?
    
    public init(viewModel: TVConductorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                // Modal Header
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("QUICK KITCHEN TWEAKS & SUBSTITUTIONS")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.orange)
                        
                        Text("Smart Culinary Customizer")
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button("Close (Back on Remote)") {
                        viewModel.isQuickActionPresented = false
                    }
                    .buttonStyle(.card)
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
                
                // Substitution & Tweak Cards Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                    // Card 1: Dairy Free Swap
                    TweakOptionCard(
                        title: "Dairy-Free Puree",
                        subtitle: "Swap Heavy Cream & Butter",
                        replacement: "Oat Cooking Cream & Cultured Cashew Fat",
                        tag: "Dietary",
                        action: {
                            viewModel.showToast("Applied: Dairy-Free Puree formulation", color: .green)
                            viewModel.isQuickActionPresented = false
                        }
                    )
                    
                    // Card 2: Shellfish Allergy Swap
                    TweakOptionCard(
                        title: "Shellfish Alternative",
                        subtitle: "Swap Jumbo Day-Boat Scallops",
                        replacement: "King Oyster Mushroom thick medallions (cross-hatched)",
                        tag: "Allergen Safe",
                        action: {
                            viewModel.showToast("Applied: King Oyster Mushroom substitution", color: .green)
                            viewModel.isQuickActionPresented = false
                        }
                    )
                    
                    // Card 3: Servings Scaler
                    TweakOptionCard(
                        title: "Scale Servings: 4 Guests",
                        subtitle: "Double ingredient measurements",
                        replacement: "Scales timers, pan volume alerts, and companion checklists",
                        tag: "Yield",
                        action: {
                            viewModel.showToast("Scaled Recipe to 4 Servings", color: .blue)
                            viewModel.isQuickActionPresented = false
                        }
                    )
                    
                    // Card 4: Unit Conversion
                    TweakOptionCard(
                        title: "Metric / Imperial",
                        subtitle: "Toggle Grams & Celsius",
                        replacement: "Currently using Metric (Grams, ml, Celsius)",
                        tag: "Units",
                        action: {
                            viewModel.showToast("Switched Units to Imperial (oz, fl oz, °F)", color: .purple)
                            viewModel.isQuickActionPresented = false
                        }
                    )
                    
                    // Card 5: Step Audio Replay
                    TweakOptionCard(
                        title: "Replay Audio Explanation",
                        subtitle: "Chef Laurent's Arrosé Technique",
                        replacement: "Rewinds current step audio by 20 seconds",
                        tag: "Masterclass",
                        action: {
                            viewModel.showToast("Replaying Chef Laurent's audio...", color: .orange)
                            viewModel.isQuickActionPresented = false
                        }
                    )
                    
                    // Card 6: Reassign Stations
                    TweakOptionCard(
                        title: "Swap Station Roles",
                        subtitle: "Switch Alex & Sarah's tasks",
                        replacement: "Alex -> Sauté & Stovetop | Sarah -> Prep & Plating",
                        tag: "Crew Sync",
                        action: {
                            viewModel.showToast("Station roles swapped successfully!", color: .cyan)
                            viewModel.isQuickActionPresented = false
                        }
                    )
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
}

private struct TweakOptionCard: View {
    let title: String
    let subtitle: String
    let replacement: String
    let tag: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(tag.uppercased())
                        .font(.system(size: 11, weight: .black))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Image(systemName: "arrow.triangle.swap")
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(replacement)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.top, 4)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.card)
    }
}
