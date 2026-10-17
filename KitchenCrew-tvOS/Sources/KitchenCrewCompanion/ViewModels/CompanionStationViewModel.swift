import Foundation
import SwiftUI
import Combine

@MainActor
public final class CompanionStationViewModel: ObservableObject {
    @Published public var userDisplayName: String = "Chef Alex"
    @Published public var assignedStation: StationRole = .prep
    @Published public var isConnectedToTV: Bool = true
    @Published public var currentStepIndex: Int = 0
    
    // Sub-station Tasks Checklist
    @Published public var stationTasks: [StationTask] = [
        StationTask(id: "task-1", title: "Pat sea scallops bone dry", detail: "Use 2 layers of paper towels, season lightly with Maldon sea salt", isCompleted: true),
        StationTask(id: "task-2", title: "Dice 2 French shallots finely", detail: "Uniform brunoise cut for even caramelization", isCompleted: true),
        StationTask(id: "task-3", title: "Strip 4 sprigs of fresh thyme", detail: "Discard woody stems, bruise leaves slightly", isCompleted: false),
        StationTask(id: "task-4", title: "Steam cauliflower florets", detail: "Cover saucepan until completely fork-tender (approx 7 mins)", isCompleted: false)
    ]
    
    // Station Countdown Timer
    @Published public var stationTimerSeconds: Int = 420
    @Published public var isTimerRunning: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        startTimerLoop()
    }
    
    public var completedCount: Int {
        stationTasks.filter { $0.isCompleted }.count
    }
    
    public var progress: Double {
        guard !stationTasks.isEmpty else { return 0 }
        return Double(completedCount) / Double(stationTasks.count)
    }
    
    public func toggleTask(id: String) {
        if let idx = stationTasks.firstIndex(where: { $0.id == id }) {
            stationTasks[idx].isCompleted.toggle()
            
            // Haptic feedback on iOS
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
            
            // Send payload to tvOS conductor via Multipeer
            let payload = SyncPayload.taskCompleted(userId: "chef-alex", taskId: stationTasks[idx].title, newProgress: progress)
            MultipeerSyncManager.shared.broadcast(payload: payload)
        }
    }
    
    private func startTimerLoop() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.isTimerRunning && self.stationTimerSeconds > 0 {
                    self.stationTimerSeconds -= 1
                }
            }
            .store(in: &cancellables)
    }
}

public struct StationTask: Identifiable, Codable {
    public let id: String
    public let title: String
    public let detail: String
    public var isCompleted: Bool
}
