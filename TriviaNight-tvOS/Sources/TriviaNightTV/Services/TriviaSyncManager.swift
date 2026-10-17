import Foundation
import MultipeerConnectivity
import Combine

public final class TriviaSyncManager: NSObject, ObservableObject {
    public static let shared = TriviaSyncManager()
    
    private let serviceType = "trivia-night"
    private let myPeerId: MCPeerID
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    
    @Published public var connectedPeers: [MCPeerID] = []
    @Published public var receivedPayload: TriviaSyncPayload?
    
    public override init() {
        let deviceName = "TriviaNight Apple TV"
        self.myPeerId = MCPeerID(displayName: deviceName)
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        self.advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: ["room": "PUB-4K"], serviceType: serviceType)
        
        super.init()
        self.session.delegate = self
        self.advertiser.delegate = self
        
        startAdvertising()
    }
    
    public func startAdvertising() {
        advertiser.startAdvertisingPeer()
    }
    
    public func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
        session.disconnect()
    }
    
    public func broadcast(payload: TriviaSyncPayload) {
        guard !session.connectedPeers.isEmpty else { return }
        do {
            let data = try JSONEncoder().encode(payload)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("[TriviaSyncManager] Broadcast error: \(error)")
        }
    }
}

extension TriviaSyncManager: MCSessionDelegate {
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
            case .connecting:
                break
            @unknown default:
                break
            }
        }
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let payload = try JSONDecoder().decode(TriviaSyncPayload.self, from: data)
            DispatchQueue.main.async {
                self.receivedPayload = payload
            }
        } catch {
            print("[TriviaSyncManager] Decode error: \(error)")
        }
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension TriviaSyncManager: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Automatically accept living room trivia buzzers
        invitationHandler(true, self.session)
    }
}
