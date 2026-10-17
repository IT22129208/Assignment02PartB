import Foundation
import SwiftUI
import Combine

@MainActor
public final class TVConductorViewModel: ObservableObject {
    @Published public var recipe: Recipe
    @Published public var currentStepIndex: Int = 0
    @Published public var activeCameraAngle: CameraAngle = .wideChef
    @Published public var isSplitScreen: Bool = false
    @Published public var isPlaying: Bool = true
    
    // Connected Crew Members (iPhones/iPads)
    @Published public var connectedChefs: [ChefUser] = [
        ChefUser(
            id: "chef-alex",
            displayName: "Chef Alex",
            deviceModel: "iPad Pro 12.9\"",
            stationRole: .prep,
            isConnected: true,
            currentSubtask: "Dicing Shallots & Prepping Puree",
            completedTasksCount: 1,
            totalTasksCount: 3
        ),
        ChefUser(
            id: "chef-sarah",
            displayName: "Chef Sarah",
            deviceModel: "iPhone 15 Pro",
            stationRole: .saute,
            isConnected: true,
            currentSubtask: "Preheating Cast Iron / Scallop Sear",
            completedTasksCount: 0,
            totalTasksCount: 3
        )
    ]
    
    // Timers
    @Published public var activeTimers: [KitchenTimer] = [
        KitchenTimer(label: "Cauliflower Steam", totalSeconds: 420, remainingSeconds: 380, isRunning: true, associatedStation: .prep),
        KitchenTimer(label: "Scallop Sear", totalSeconds: 90, remainingSeconds: 90, isRunning: false, associatedStation: .saute)
    ]
    
    // Quick Action & Modals
    @Published public var isQuickActionPresented: Bool = false
    @Published public var activeToastMessage: String?
    @Published public var activeToastColor: Color = .orange
    
    // Voice State
    @Published public var isVoiceActive: Bool = false
    @Published public var lastVoiceQuery: String = "Voice Conductor Ready (\"Hey Siri, next step\")"
    
    private var timerCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private let syncManager = MultipeerSyncManager.shared
    private let voiceService = KitchenVoiceService.shared
    private let audioEngine = AudioFeedbackEngine.shared
    
    public init(recipe: Recipe = Recipe.sampleScallops) {
        self.recipe = recipe
        setupTimerLoop()
        bindSyncManager()
        bindVoiceService()
    }
    
    public var currentStep: RecipeStep {
        guard currentStepIndex >= 0 && currentStepIndex < recipe.steps.count else {
            return recipe.steps[0]
        }
        return recipe.steps[currentStepIndex]
    }
    
    public var currentProgress: Double {
        guard !recipe.steps.isEmpty else { return 0 }
        return Double(currentStepIndex + 1) / Double(recipe.steps.count)
    }
    
    // MARK: - Navigation & Flow
    public func nextStep() {
        if currentStepIndex < recipe.steps.count - 1 {
            recipe.steps[currentStepIndex].isCompleted = true
            currentStepIndex += 1
            audioEngine.play(.stepCompleted)
            showToast("Advanced to Step \(currentStepIndex + 1): \(currentStep.title)", color: .blue)
            
            // Automatically switch camera angle to match step recommendation
            self.activeCameraAngle = currentStep.recommendedAngle
            
            // Broadcast to companion devices
            syncManager.broadcast(payload: .stepChange(newIndex: currentStepIndex))
        }
    }
    
    public func previousStep() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
            audioEngine.play(.focusNavigation)
            syncManager.broadcast(payload: .stepChange(newIndex: currentStepIndex))
        }
    }
    
    public func togglePlayPause() {
        isPlaying.toggle()
        audioEngine.play(.focusNavigation)
    }
    
    public func setCameraAngle(_ angle: CameraAngle) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            self.activeCameraAngle = angle
        }
        audioEngine.play(.focusNavigation)
        syncManager.broadcast(payload: .cameraAngleChanged(angle: angle))
    }
    
    public func toggleSplitScreen() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            self.isSplitScreen.toggle()
        }
        audioEngine.play(.focusNavigation)
    }
    
    // MARK: - Timer Management
    public func startOrPauseTimer(id: UUID) {
        if let idx = activeTimers.firstIndex(where: { $0.id == id }) {
            activeTimers[idx].isRunning.toggle()
            audioEngine.play(.focusNavigation)
            syncManager.broadcast(payload: .timerUpdate(timer: activeTimers[idx]))
        }
    }
    
    public func addTimer(label: String, seconds: Int, station: StationRole? = nil) {
        let newTimer = KitchenTimer(label: label, totalSeconds: seconds, remainingSeconds: seconds, isRunning: true, associatedStation: station)
        activeTimers.append(newTimer)
        audioEngine.play(.timerDing)
        showToast("Started timer for '\(label)' (\(seconds / 60)m)", color: .green)
        syncManager.broadcast(payload: .timerUpdate(timer: newTimer))
    }
    
    private func setupTimerLoop() {
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                for idx in self.activeTimers.indices {
                    if self.activeTimers[idx].isRunning && self.activeTimers[idx].remainingSeconds > 0 {
                        self.activeTimers[idx].remainingSeconds -= 1
                        if self.activeTimers[idx].remainingSeconds == 0 {
                            self.activeTimers[idx].isRunning = false
                            self.audioEngine.play(.timerDing)
                            self.showToast("🔔 Timer Done: \(self.activeTimers[idx].label)!", color: .red)
                        }
                    }
                }
            }
    }
    
    // MARK: - Sub-station Remote Synchronization
    private func bindSyncManager() {
        syncManager.$receivedPayload
            .compactMap { $0 }
            .sink { [weak self] payload in
                self?.handleRemotePayload(payload)
            }
            .store(in: &cancellables)
    }
    
    private func handleRemotePayload(_ payload: SyncPayload) {
        switch payload {
        case .taskCompleted(let userId, let taskId, let newProgress):
            if let idx = connectedChefs.firstIndex(where: { $0.id == userId }) {
                connectedChefs[idx].completedTasksCount += 1
                audioEngine.play(.stepCompleted)
                showToast("✨ \(connectedChefs[idx].displayName) completed: \(taskId)!", color: .cyan)
            }
        case .stepChange(let newIndex):
            self.currentStepIndex = newIndex
        case .timerUpdate(let updatedTimer):
            if let idx = activeTimers.firstIndex(where: { $0.id == updatedTimer.id }) {
                activeTimers[idx] = updatedTimer
            } else {
                activeTimers.append(updatedTimer)
            }
        default:
            break
        }
    }
    
    // MARK: - Hands-free Kitchen Voice Commands
    private func bindVoiceService() {
        voiceService.$detectedIntent
            .compactMap { $0 }
            .sink { [weak self] intent in
                self?.handleVoiceIntent(intent)
            }
            .store(in: &cancellables)
            
        voiceService.$liveTranscript
            .assign(to: &$lastVoiceQuery)
    }
    
    public func toggleVoiceConductor() {
        if voiceService.isListening {
            voiceService.stopListening()
            self.isVoiceActive = false
        } else {
            do {
                try voiceService.startListening()
                self.isVoiceActive = true
            } catch {
                print("Voice error: \(error)")
            }
        }
    }
    
    public func handleVoiceIntent(_ intent: VoiceIntent) {
        switch intent {
        case .nextStep:
            nextStep()
        case .previousStep:
            previousStep()
        case .repeatInstruction:
            showToast("Repeating: \(currentStep.instruction)", color: .orange)
        case .switchCamera(let angle):
            setCameraAngle(angle)
            showToast("Camera switched to: \(angle.rawValue)", color: .purple)
        case .toggleSplitScreen:
            toggleSplitScreen()
        case .startTimer(let seconds, let label):
            addTimer(label: label, seconds: seconds, station: currentStep.assignedStation)
        case .querySubstitution(let ingredient):
            isQuickActionPresented = true
            showToast("Showing chef substitutions for: \(ingredient)", color: .teal)
        case .queryStationStatus(let role):
            if let chef = connectedChefs.first(where: { $0.stationRole == role }) {
                showToast("\(chef.displayName) is \(Int(chef.completionPercentage * 100))% done with \(chef.currentSubtask)", color: .blue)
            }
        case .pauseResumeTimer:
            if let first = activeTimers.first {
                startOrPauseTimer(id: first.id)
            }
        case .unknown:
            break
        }
    }
    
    public func showToast(_ message: String, color: Color = .orange) {
        self.activeToastMessage = message
        self.activeToastColor = color
        
        Task {
            try? await Task.sleep(nanoseconds: 3_500_000_000)
            if self.activeToastMessage == message {
                self.activeToastMessage = nil
            }
        }
    }
}
