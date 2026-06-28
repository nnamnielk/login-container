#!/usr/bin/env bash
# ── Hermes Agent installer ───────────────────────────────────────────
# Override this script to install your Hermes Agent into /opt/hermes
set -e

HERMES_DIR="${HERMES_DIR:-/opt/hermes}"
USERNAME="${1:-user}"

echo "==> installing Hermes Agent into $HERMES_DIR"

mkdir -p "$HERMES_DIR"

# ── placeholder: replace with your actual install ───────────────────
# Example — clone a private repo:
#   git clone https://github.com/your-org/hermes-agent.git "$HERMES_DIR"
#   cd "$HERMES_DIR" && pip install -e .

# For now, create a stub that signals this needs configuration:
cat > "$HERMES_DIR/README.txt" <<'EOF'
Hermes Agent — stub
Replace scripts/install-hermes.sh with your actual installer.
Expected layout:
  /opt/hermes/
    agent.py        # main entrypoint
    config.yaml     # agent configuration
    skills/         # skill definitions
    memories/       # persistent memory store
EOF

chown -R "$USERNAME:$USERNAME" "$HERMES_DIR" 2>/dev/null || true
echo "[hermes] installed (stub)"
