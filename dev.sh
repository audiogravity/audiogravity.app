#!/bin/bash
cd "$(dirname "$0")"

PORT="${PORT:-8080}"

# Detect the LAN IP just for the printed URL (override with AG_DEV_HOST).
# The server itself binds to all interfaces, so it starts regardless of the IP.
HOST="${AG_DEV_HOST:-$(ip route get 1.1.1.1 2>/dev/null | awk '{for (i=1;i<=NF;i++) if ($i=="src") {print $(i+1); exit}}')}"
[ -z "$HOST" ] && HOST=$(hostname -I 2>/dev/null | awk '{print $1}')
[ -z "$HOST" ] && HOST="localhost"

echo "Landing page: http://${HOST}:${PORT}"

python3 -c "
import http.server, os
os.chdir('$(dirname "$0")')
class H(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/': self.path = '/index.html'
        return super().do_GET()
    def log_message(self, *a): pass
http.server.HTTPServer(('', $PORT), H).serve_forever()
"
