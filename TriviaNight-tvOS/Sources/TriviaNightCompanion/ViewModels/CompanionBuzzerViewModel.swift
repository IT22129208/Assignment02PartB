import Foundation
import SwiftUI
import Combine
import MultipeerConnectivity

@MainActor
public final class CompanionBuzzerViewModel: ObservableObject {
    @Published public var hasJoined: Bool = false
    @Published public var inputName: String = ""
    @Published public var playerName: String = ""
    @Published public var selectedAvatar: String = "sparkles"
    @Published public var selectedColorHex: String = "#f43f5e"
    @Published public var isConnectedToTV: Bool = true
    @Published public var selectedAnswerIndex: Int? = nil
    @Published public var isLockedIn: Bool = false
    @Published public var roomCode: String = "PUB-4K"
    
    public var playerId: String = "player-mobile"
    
    public let availableAvatars = ["sparkles", "bolt.fill", "flame.fill", "star.fill", "heart.fill", "gamecontroller.fill"]
    public let availableColors = ["#f43f5e", "#0ea5e9", "#eab308", "#a855f7", "#10b981", "#ec4899"]
    
    private let peerId: MCPeerID
    private var session: MCSession
    private var browser: MCNearbyServiceBrowser
    
    public init() {
        self.peerId = MCPeerID(displayName: "Player's iPhone")
        self.session = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        self.browser = MCNearbyServiceBrowser(peer: peerId, serviceType: "trivia-night")
        
        startBrowsing()
    }
    
    public func startBrowsing() {
        browser.startBrowsingForPeers()
    }
    
    public func updateLiveNameDraft(name: String, avatar: String, colorHex: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        self.playerName = trimmed
        self.selectedAvatar = avatar
        self.selectedColorHex = colorHex
        
        let player = Player(
            id: self.playerId,
            name: trimmed,
            avatarIcon: avatar,
            colorHex: colorHex,
            controllerType: .companionPhone
        )
        TriviaSyncManager.shared.broadcast(payload: .playerJoin(player: player))
    }
    
    public func joinRoom(name: String, avatar: String, colorHex: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmed.isEmpty ? "Player" : trimmed
        self.playerName = finalName
        self.selectedAvatar = avatar
        self.selectedColorHex = colorHex
        self.hasJoined = true
        self.playerId = "player-mobile-\(abs(finalName.hashValue % 10000))"
        
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        #endif
        
        let player = Player(
            id: self.playerId,
            name: finalName,
            avatarIcon: avatar,
            colorHex: colorHex,
            controllerType: .companionPhone
        )
        
        TriviaSyncManager.shared.broadcast(payload: .playerJoin(player: player))
    }
    
    public func editProfile() {
        self.hasJoined = false
    }
    
    public func selectAnswer(index: Int) {
        guard !isLockedIn else { return }
        selectedAnswerIndex = index
        isLockedIn = true
        
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        #endif
        
        // Transmit answer payload to Apple TV
        let payload = TriviaSyncPayload.playerAnswer(
            playerId: self.playerId,
            answerIndex: index,
            timeElapsed: 2.1
        )
        TriviaSyncManager.shared.broadcast(payload: payload)
    }
    
    public func resetForNextQuestion() {
        selectedAnswerIndex = nil
        isLockedIn = false
    }
}
