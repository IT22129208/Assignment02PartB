import SwiftUI

public struct CrewStationStatusStripView: View {
    let chefs: [ChefUser]
    
    public init(chefs: [ChefUser]) {
        self.chefs = chefs
    }
    
    public var body: some View {
        HStack(spacing: 24) {
            ForEach(chefs) { chef in
                HStack(spacing: 16) {
                    // Station Badge & Role Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: chef.stationRole.colorHex).opacity(0.2))
                            .frame(width: 52, height: 52)
                        
                        Image(systemName: chef.stationRole.icon)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: chef.stationRole.colorHex))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(chef.displayName)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            
                            // Connected status indicator
                            Circle()
                                .fill(chef.isConnected ? Color.green : Color.gray)
                                .frame(width: 8, height: 8)
                            
                            Text(chef.deviceModel)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Text(chef.currentSubtask)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                        
                        // Progress bar for station tasks
                        HStack(spacing: 8) {
                            GeometryReader { pGeo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(height: 6)
                                    
                                    Capsule()
                                        .fill(Color(hex: chef.stationRole.colorHex))
                                        .frame(width: max(pGeo.size.width * CGFloat(chef.completionPercentage), 6), height: 6)
                                }
                            }
                            .frame(height: 6)
                            
                            Text("\(chef.completedTasksCount)/\(chef.totalTasksCount)")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(width: 220)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.black.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color(hex: chef.stationRole.colorHex).opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }
}
