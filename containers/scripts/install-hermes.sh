#!/usr/bin/env bash
# ── Hermes Agent installer ───────────────────────────────────────────
# Installs Hermes Agent into /opt/hermes with pip + systemd user service
set -e

HERMES_DIR="${HERMES_DIR:-/opt/hermes}"
USERNAME="${1:-user}"
HOME_DIR="/home/${USERNAME}"

echo "==> installing Hermes Agent into $HERMES_DIR"

# ── install via pip ──────────────────────────────────────────────────
pip3 install --break-system-packages hermes-agent 2>/dev/null || {
    # Fallback: install from GitHub if pip package not available
    echo "  pip install failed, cloning from GitHub..."
    git clone --depth 1 https://github.com/nous/hermes-agent.git "$HERMES_DIR"
    pip3 install --break-system-packages -e "$HERMES_DIR"
}

# ── first-run setup ──────────────────────────────────────────────────
if command -v hermes &>/dev/null; then
    # Initialize hermes config (non-interactive, skip if already exists)
    if [ ! -f "$HOME_DIR/.hermes/config.yaml" ]; then
        sudo -u "$USERNAME" mkdir -p "$HOME_DIR/.hermes"
        sudo -u "$USERNAME" hermes init --non-interactive 2>/dev/null || true
    fi

    # Generate a default config if init didn't create one
    if [ ! -f "$HOME_DIR/.hermes/config.yaml" ]; then
        cat > "$HOME_DIR/.hermes/config.yaml" <<'YAML'
# Hermes Agent configuration
# see: https://hermes-agent.nousresearch.com/docs
model:
  provider: anthropic
  model: claude-sonnet-4
tools:
  terminal: true
  web: true
  file: true
YAML
        chown "$USERNAME:$USERNAME" "$HOME_DIR/.hermes/config.yaml"
    fi

    echo "[hermes] installed successfully ($(hermes --version 2>/dev/null || echo 'unknown version'))"
else
    echo "[hermes] WARNING: hermes CLI not found on PATH after install"
fi

# ── systemd user service (auto-start hermes on login) ────────────────
mkdir -p "$HOME_DIR/.config/systemd/user"
cat > "$HOME_DIR/.config/systemd/user/hermes-agent.service" <<'UNIT'
[Unit]
Description=Hermes Agent
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/hermes serve
Restart=on-failure
RestartSec=5
Environment=HOME=%h

[Install]
WantedBy=default.target
UNIT

chown -R "$USERNAME:$USERNAME" "$HERMES_DIR" 2>/dev/null || true
echo "[hermes] done"
