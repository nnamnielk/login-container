#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "============================================"
echo " Building ubuntu-riced container"
echo "============================================"

# ── build the image ──────────────────────────────────────────────────
docker compose build --no-cache

echo ""
echo "============================================"
echo " Build complete!"
echo "============================================"
echo ""
echo " Start the containers:"
echo "   docker compose up -d alice bob"
echo ""
echo " Or use make:"
echo "   make up"
echo ""
echo " Access desktops:"
echo "   Alice → http://localhost:6081/vnc.html"
echo "   Bob   → http://localhost:6082/vnc.html"
echo ""
echo " SSH:"
echo "   ssh -p 2201 alice@localhost   (password: changeme)"
echo "   ssh -p 2202 bob@localhost     (password: changeme)"
echo ""
echo " Inject SSH keys (optional):"
echo "   SSH_PUBLIC_KEY=\"ssh-ed25519 AAAA...\" docker compose up -d"
