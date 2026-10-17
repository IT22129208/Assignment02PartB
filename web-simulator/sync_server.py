import http.server
import socketserver
import json
import os
import sys
import time
import socket
import threading
from urllib.parse import urlparse, parse_qs

PORT = 3000
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Shared state
GAME_STATE = {
    "state": "lobby",
    "selectedCategory": "math",
    "currentQuestionIndex": 0,
    "timeRemaining": 15.0,
    "totalQuestionTime": 15.0,
    "isTimerRunning": False,
    "toastMessage": None,
    "toastColor": None,
    "players": [
        {
            "id": "player-remote",
            "name": "Host (Siri Remote)",
            "avatar": "🎮",
            "color": "#38bdf8",
            "controller": "Siri Remote",
            "score": 0,
            "streak": 0,
            "selectedAnswer": None,
            "isLockedIn": False,
            "answerTime": None,
            "isReady": True
        },
        {
            "id": "player-mobile",
            "name": "Alex",
            "avatar": "✨",
            "color": "#f43f5e",
            "controller": "iPhone",
            "score": 0,
            "streak": 0,
            "selectedAnswer": None,
            "isLockedIn": False,
            "answerTime": None,
            "isReady": True
        }
    ],
    "lastEvent": None
}

# Active SSE client queues
SSE_CLIENTS = []
SSE_LOCK = threading.Lock()

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = '127.0.0.1'
    finally:
        s.close()
    return ip

def broadcast_event(event_type, data):
    payload = json.dumps({"type": event_type, "data": data, "timestamp": time.time()})
    with SSE_LOCK:
        dead_clients = []
        for client in SSE_CLIENTS:
            try:
                client.write(f"data: {payload}\n\n".encode('utf-8'))
                client.flush()
            except Exception:
                dead_clients.append(client)
        for d in dead_clients:
            if d in SSE_CLIENTS:
                SSE_CLIENTS.remove(d)

class SyncHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BASE_DIR, **kwargs)

    def log_message(self, format, *args):
        # Silence routine static asset logging to keep terminal clean
        if args and any(str(args[0]).startswith(p) for p in ['/js/', '/styles/', '/assets/']):
            return
        super().log_message(format, *args)

    def do_GET(self):
        parsed = urlparse(self.path)
        
        # Server-Sent Events Endpoint
        if parsed.path == '/api/sync/events':
            self.send_response(200)
            self.send_header('Content-Type', 'text/event-stream')
            self.send_header('Cache-Control', 'no-cache')
            self.send_header('Connection', 'keep-alive')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            
            with SSE_LOCK:
                SSE_CLIENTS.append(self.wfile)
            
            # Send initial sync
            initial = json.dumps({"type": "init", "state": GAME_STATE})
            try:
                self.wfile.write(f"data: {initial}\n\n".encode('utf-8'))
                self.wfile.flush()
                while True:
                    time.sleep(15)
                    self.wfile.write(b": heartbeat\n\n")
                    self.wfile.flush()
            except (ConnectionResetError, BrokenPipeError):
                with SSE_LOCK:
                    if self.wfile in SSE_CLIENTS:
                        SSE_CLIENTS.remove(self.wfile)
            return

        # State Snapshot Endpoint
        if parsed.path == '/api/sync/state':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(GAME_STATE).encode('utf-8'))
            return

        # Network Info Endpoint
        if parsed.path == '/api/sync/info':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            info = {
                "localIp": get_local_ip(),
                "port": PORT,
                "mobileUrl": f"http://{get_local_ip()}:{PORT}/?mode=mobile",
                "tvUrl": f"http://{get_local_ip()}:{PORT}/?mode=tv"
            }
            self.wfile.write(json.dumps(info).encode('utf-8'))
            return

        # Normal static file serving
        return super().do_GET()

    def do_POST(self):
        parsed = urlparse(self.path)
        content_len = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_len).decode('utf-8')
        try:
            data = json.loads(body) if body else {}
        except Exception:
            data = {}

        if parsed.path == '/api/sync/update-player':
            player_id = data.get('id', 'player-mobile')
            name = data.get('name', '').strip()
            avatar = data.get('avatar')
            color = data.get('color')
            is_ready = data.get('isReady', True)

            # Find or append player
            player = next((p for p in GAME_STATE['players'] if p['id'] == player_id), None)
            if not player:
                player = {
                    "id": player_id,
                    "name": name or "Player",
                    "avatar": avatar or "✨",
                    "color": color or "#f43f5e",
                    "controller": "iPhone",
                    "score": 0,
                    "streak": 0,
                    "selectedAnswer": None,
                    "isLockedIn": False,
                    "answerTime": None,
                    "isReady": is_ready
                }
                GAME_STATE['players'].append(player)
            else:
                if name: player['name'] = name
                if avatar: player['avatar'] = avatar
                if color: player['color'] = color
                player['isReady'] = is_ready

            broadcast_event('playerUpdate', player)
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({"success": True, "player": player}).encode('utf-8'))
            return

        if parsed.path == '/api/sync/answer':
            player_id = data.get('playerId')
            answer_idx = data.get('answerIndex')
            player = next((p for p in GAME_STATE['players'] if p['id'] == player_id), None)
            if player:
                player['selectedAnswer'] = answer_idx
                player['isLockedIn'] = True
                player['answerTime'] = data.get('answerTime', 2.0)
                broadcast_event('playerAnswer', {
                    "playerId": player_id,
                    "answerIndex": answer_idx,
                    "name": player['name'],
                    "avatar": player['avatar'],
                    "color": player['color']
                })
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({"success": True}).encode('utf-8'))
            return

        if parsed.path == '/api/sync/game-state':
            for k, v in data.items():
                if k in GAME_STATE:
                    GAME_STATE[k] = v
            broadcast_event('gameState', data)
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({"success": True}).encode('utf-8'))
            return

        self.send_response(404)
        self.end_headers()

class ThreadedHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True

if __name__ == '__main__':
    local_ip = get_local_ip()
    print("=" * 60)
    print(f"🍻 TriviaNight TV Real-Time Sync Server")
    print(f"📺 Apple TV Display:   http://localhost:{PORT}/?mode=tv")
    print(f"📱 Mobile Controller: http://localhost:{PORT}/?mode=mobile")
    print(f"🖥️  Split Simulator:    http://localhost:{PORT}/")
    print(f"🌐 On your iPhone:    http://{local_ip}:{PORT}/?mode=mobile")
    print("=" * 60)
    
    server = ThreadedHTTPServer(('0.0.0.0', PORT), SyncHTTPRequestHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.server_close()
