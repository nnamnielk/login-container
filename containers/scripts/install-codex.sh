#!/usr/bin/env bash
# ── Codex CLI installer ──────────────────────────────────────────────
# Installs OpenAI Codex CLI into /opt/codex
# For the desktop app: drop codex-desktop binary + icon.png into /opt/codex/
set -e

CODEX_DIR="${CODEX_DIR:-/opt/codex}"
USERNAME="${1:-user}"
HOME_DIR="/home/${USERNAME}"

echo "==> installing Codex CLI into $CODEX_DIR"

mkdir -p "$CODEX_DIR"

# ── install codex CLI via npm ────────────────────────────────────────
# OpenAI Codex CLI: open-source coding agent
if command -v npm &>/dev/null; then
    npm install -g @openai/codex 2>/dev/null || {
        echo "  npm install failed, trying pip fallback..."
        pip3 install --break-system-packages openai-codex 2>/dev/null || true
    }
elif command -v pip3 &>/dev/null; then
    pip3 install --break-system-packages openai-codex 2>/dev/null || true
fi

# ── verify ──────────────────────────────────────────────────────────
if command -v codex &>/dev/null; then
    echo "[codex] CLI installed successfully ($(codex --version 2>/dev/null || echo 'unknown version'))"
else
    echo "[codex] WARNING: codex CLI not installed (npm or pip failed)"
    echo "[codex] Manual install: npm install -g @openai/codex"
fi

# ── desktop entry (for GUI app if user drops binary) ─────────────────
mkdir -p "/usr/share/applications"
cat > "/usr/share/applications/codex-desktop.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Codex Desktop
Comment=AI Coding Agent
Exec=/opt/codex/codex-desktop
Icon=/opt/codex/icon.png
Terminal=false
Categories=Development;IDE;
StartupWMClass=codex-desktop
DESKTOP

# ── indicate what's needed for the desktop app ───────────────────────
cat > "$CODEX_DIR/README.txt" <<'EOF'
Codex Desktop — setup instructions
===================================

CLI (installed automatically):
  The OpenAI Codex CLI is installed via npm/pip if available.
  Run: codex --help

Desktop App (manual):
  1. Download the Codex Desktop AppImage from openai.com
  2. Place it at: /opt/codex/codex-desktop
  3. Place an icon at: /opt/codex/icon.png
  4. chmod +x /opt/codex/codex-desktop
  5. The .desktop entry is already configured — it will appear
     in the Cinnamon application menu under Development > Codex Desktop
EOF

chown -R "$USERNAME:$USERNAME" "$CODEX_DIR" 2>/dev/null || true
echo "[codex] done"
