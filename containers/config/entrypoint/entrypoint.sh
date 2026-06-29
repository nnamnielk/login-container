#!/usr/bin/env bash
set -e

# ── per‑instance identity (set via docker‑compose environment) ──────────
USERNAME="${CONTAINER_USER:-user}"
SSH_PORT="${SSH_PORT:-22}"

echo "==> bootstraping container for: $USERNAME"

# ── create the user if it doesn't exist ─────────────────────────────────
if ! id "$USERNAME" &>/dev/null; then
    useradd -m -s /usr/bin/zsh -G sudo "$USERNAME"
    echo "$USERNAME:changeme" | chpasswd
    # copy riced configs into user home
    cp -r /root/.config/* "/home/$USERNAME/.config/"
    cp /root/.zshrc "/home/$USERNAME/.zshrc" 2>/dev/null || true
    cp -r /root/.oh-my-zsh "/home/$USERNAME/.oh-my-zsh" 2>/dev/null || true
    mkdir -p "/home/$USERNAME/.vnc"
    x11vnc -storepasswd changeme "/home/$USERNAME/.vnc/passwd"
    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"
fi

# ── hermes agent + codex + webui (first-run install) ──────────────────
if [ ! -f /opt/hermes/.installed ]; then
    /usr/local/bin/install-hermes.sh "$USERNAME" && touch /opt/hermes/.installed || true
fi
if [ ! -f /opt/codex/.installed ]; then
    /usr/local/bin/install-codex.sh "$USERNAME" && touch /opt/codex/.installed || true
fi
if [ ! -f /opt/hermes-webui/.installed ]; then
    /usr/local/bin/install-webui.sh "$USERNAME" && touch /opt/hermes-webui/.installed || true
fi

# ── ssh key injection ──────────────────────────────────────────────────
if [ -n "$SSH_PUBLIC_KEY" ]; then
    mkdir -p "/home/$USERNAME/.ssh"
    echo "$SSH_PUBLIC_KEY" >> "/home/$USERNAME/.ssh/authorized_keys"
    chmod 700 "/home/$USERNAME/.ssh"
    chmod 600 "/home/$USERNAME/.ssh/authorized_keys"
    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh"
fi

# ── start dbus (needed by desktop) ─────────────────────────────────────
mkdir -p /run/dbus
dbus-daemon --system --fork || true

# ── start virtual display ──────────────────────────────────────────────
export DISPLAY="${DISPLAY:-:99}"
Xvfb "$DISPLAY" -screen 0 "${RESOLUTION:-1920x1080x24}" \
    -ac +extension RANDR +extension GLX &
sleep 1

# ── start cinnamon desktop ─────────────────────────────────────────────
cinnamon-session &
sleep 3

# ── start x11vnc ───────────────────────────────────────────────────────
x11vnc -display "$DISPLAY" -forever -shared -rfbauth "/home/$USERNAME/.vnc/passwd" \
    -rfbport "${VNC_PORT:-5901}" -quiet &
sleep 1

# ── start novnc (web vnc client) ───────────────────────────────────────
websockify --web /usr/share/novnc "${NOVNC_PORT:-6080}" \
    "localhost:${VNC_PORT:-5901}" &

# ── start jupyterlab ────────────────────────────────────────────────────
JUPYTER_PORT="${JUPYTER_PORT:-8888}"
mkdir -p "/home/$USERNAME/notebooks"
sed -i "s|c.ServerApp.root_dir.*|c.ServerApp.root_dir = '/home/$USERNAME/notebooks'|" \
    /root/.jupyter/jupyter_lab_config.py 2>/dev/null || true
jupyter lab --config=/root/.jupyter/jupyter_lab_config.py --port="$JUPYTER_PORT" &

# ── start sshd ─────────────────────────────────────────────────────────
echo "==> starting sshd on port $SSH_PORT"
exec /usr/sbin/sshd -D -p "$SSH_PORT"
