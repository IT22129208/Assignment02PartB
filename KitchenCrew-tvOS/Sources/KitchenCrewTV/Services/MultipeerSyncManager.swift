import Foundation
import MultipeerConnectivity
import Combine

public final class MultipeerSyncManager: NSObject, ObservableObject {
    public static let shared = MultipeerSyncManager()
    
    private let serviceType = "kitchen-crew"
    private let myPeerId: MCPeerID
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    
    @Published public var connectedPeers: [MCPeerID] = []
    @Published public var receivedPayload: SyncPayload?
    
    public override init() {
        // In tvOS, the Apple TV acts as the host conductor
        let deviceName = "KitchenCrew Apple TV 4K"
        self.myPeerId = MCPeerID(displayName: deviceName)
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        self.advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: ["role": "conductor"], serviceType: serviceType)
        
        super.init()
        self.session.delegate = self
        self.advertiser.delegate = self
        
        startBroadcasting()
    }
    
    public func startBroadcasting() {
        advertiser.startAdvertisingPeer()
    }
    
    public func stopBroadcasting() {
        advertiser.stopAdvertisingPeer()
        session.disconnect()
    }
    
    public func broadcast(payload: SyncPayload) {
        guard !session.connectedPeers.isEmpty else { return }
        do {
            let data = try JSONEncoder().encode(payload)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("[MultipeerSyncManager] Broadcast error: \(error)")
        }
    }
}

extension MultipeerSyncManager: MCSessionDelegate {
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
            let payload = try JSONDecoder().decode(SyncPayload.self, from: data)
            DispatchQueue.main.async {
                self.receivedPayload = payload
            }
        } catch {
            print("[MultipeerSyncManager] Decode error: \(error)")
        }
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension MultipeerSyncManager: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Automatically accept kitchen crew members (iPhones/iPads in the household)
        invitationHandler(true, self.session)
    }
}
