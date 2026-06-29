#!/usr/bin/env bash
# ── Hermes WebUI installer ───────────────────────────────────────────
# Installs the Hermes WebUI browser interface alongside Hermes Agent.
# The WebUI is a thin Python server (server.py + api/) that connects to
# the Hermes Agent config in the user's ~/.hermes directory.
set -e

WEBUI_DIR="${WEBUI_DIR:-/opt/hermes-webui}"
USERNAME="${1:-user}"
HOME_DIR="/home/${USERNAME}"
WEBUI_PORT="${WEBUI_PORT:-8787}"

echo "==> installing Hermes WebUI into $WEBUI_DIR"

# ── clone from GitHub ────────────────────────────────────────────────
if [ ! -d "$WEBUI_DIR/.git" ]; then
    git clone --depth 1 https://github.com/NousResearch/hermes-agent.git "$WEBUI_DIR"
else
    cd "$WEBUI_DIR" && git pull --ff-only origin main 2>/dev/null || true
fi

# ── set up Python venv ───────────────────────────────────────────────
python3 -m venv "$WEBUI_DIR/venv" 2>/dev/null || python3 -m venv --without-pip "$WEBUI_DIR/venv"
"$WEBUI_DIR/venv/bin/pip" install --quiet --upgrade pip 2>/dev/null || true
"$WEBUI_DIR/venv/bin/pip" install --quiet pyyaml cryptography

# ── per-user state directory ─────────────────────────────────────────
STATE_DIR="$HOME_DIR/.hermes/webui"
mkdir -p "$STATE_DIR/sessions" "$STATE_DIR/workspaces"
chown -R "$USERNAME:$USERNAME" "$STATE_DIR" 2>/dev/null || true

# ── systemd user service ─────────────────────────────────────────────
mkdir -p "$HOME_DIR/.config/systemd/user"
cat > "$HOME_DIR/.config/systemd/user/hermes-webui.service" <<UNIT
[Unit]
Description=Hermes WebUI
After=network-online.target hermes-agent.service
Wants=network-online.target

[Service]
Type=simple
ExecStart=$WEBUI_DIR/venv/bin/python $WEBUI_DIR/server.py
Restart=on-failure
RestartSec=5
Environment=HOME=$HOME_DIR
Environment=HERMES_HOME=$HOME_DIR/.hermes
Environment=HERMES_WEBUI_HOST=0.0.0.0
Environment=HERMES_WEBUI_PORT=$WEBUI_PORT
Environment=HERMES_WEBUI_STATE_DIR=$STATE_DIR
Environment=HERMES_WEBUI_DEFAULT_WORKSPACE=/home/$USERNAME
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=default.target
UNIT

# ── desktop entry (launch in browser) ────────────────────────────────
mkdir -p "/usr/share/applications"
cat > "/usr/share/applications/hermes-webui.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Hermes WebUI
Comment=AI Agent Chat Interface
Exec=xdg-open http://localhost:$WEBUI_PORT
Icon=$WEBUI_DIR/static/favicon-192.png
Terminal=false
Categories=Development;AI;
DESKTOP

chown -R "$USERNAME:$USERNAME" "$WEBUI_DIR" 2>/dev/null || true
echo "[webui] installed — http://localhost:$WEBUI_PORT"
echo "[webui] systemd service: systemctl --user enable --now hermes-webui"
