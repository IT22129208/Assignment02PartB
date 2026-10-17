import SwiftUI

public struct StationChecklistView: View {
    @StateObject private var viewModel = CompanionStationViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // TV Sync Connection Banner
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(viewModel.isConnectedToTV ? Color.green : Color.orange)
                            .frame(width: 10, height: 10)
                        
                        Text(viewModel.isConnectedToTV ? "Synced with Apple TV 4K" : "Connecting...")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text(viewModel.assignedStation.rawValue)
                        .font(.system(size: 12, weight: .black))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: viewModel.assignedStation.colorHex).opacity(0.2))
                        .foregroundColor(Color(hex: viewModel.assignedStation.colorHex))
                        .clipShape(Capsule())
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // Station Timer Card
                VStack(spacing: 8) {
                    Text("STATION TIMER")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                    
                    let mins = viewModel.stationTimerSeconds / 60
                    let secs = viewModel.stationTimerSeconds % 60
                    Text(String(format: "%02d:%02d", mins, secs))
                        .font(.system(size: 48, weight: .heavy, design: .monospaced))
                        .foregroundColor(.orange)
                    
                    Text("Cauliflower Steam")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal)
                
                // Sub-station Task Checklist
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("MY STATION TASKS")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(viewModel.completedCount) OF \(viewModel.stationTasks.count) DONE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.cyan)
                    }
                    .padding(.horizontal)
                    
                    List {
                        ForEach(viewModel.stationTasks) { task in
                            Button(action: {
                                viewModel.toggleTask(id: task.id)
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 24))
                                        .foregroundColor(task.isCompleted ? .cyan : .white.opacity(0.4))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(task.title)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(task.isCompleted ? .white.opacity(0.5) : .white)
                                            .strikethrough(task.isCompleted)
                                        
                                        Text(task.detail)
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.white.opacity(0.05))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("KitchenCrew Station")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
