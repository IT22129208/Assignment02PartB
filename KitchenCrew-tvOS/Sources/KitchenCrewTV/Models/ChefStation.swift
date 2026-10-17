import Foundation

public struct ChefUser: Identifiable, Codable, Hashable {
    public let id: String
    public let displayName: String
    public let deviceModel: String
    public var stationRole: StationRole
    public var isConnected: Bool
    public var currentSubtask: String
    public var completedTasksCount: Int
    public var totalTasksCount: Int
    
    public init(
        id: String,
        displayName: String,
        deviceModel: String,
        stationRole: StationRole,
        isConnected: Bool = true,
        currentSubtask: String = "",
        completedTasksCount: Int = 0,
        totalTasksCount: Int = 0
    ) {
        self.id = id
        self.displayName = displayName
        self.deviceModel = deviceModel
        self.stationRole = stationRole
        self.isConnected = isConnected
        self.currentSubtask = currentSubtask
        self.completedTasksCount = completedTasksCount
        self.totalTasksCount = totalTasksCount
    }
    
    public var completionPercentage: Double {
        guard totalTasksCount > 0 else { return 0 }
        return Double(completedTasksCount) / Double(totalTasksCount)
    }
}

public struct KitchenTimer: Identifiable, Codable, Hashable {
    public let id: UUID
    public let label: String
    public let totalSeconds: Int
    public var remainingSeconds: Int
    public var isRunning: Bool
    public let associatedStation: StationRole?
    
    public init(
        id: UUID = UUID(),
        label: String,
        totalSeconds: Int,
        remainingSeconds: Int? = nil,
        isRunning: Bool = false,
        associatedStation: StationRole? = nil
    ) {
        self.id = id
        self.label = label
        self.totalSeconds = totalSeconds
        self.remainingSeconds = remainingSeconds ?? totalSeconds
        self.isRunning = isRunning
        self.associatedStation = associatedStation
    }
    
    public var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
    }
    
    public var formattedTime: String {
        let mins = remainingSeconds / 60
        let secs = remainingSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
