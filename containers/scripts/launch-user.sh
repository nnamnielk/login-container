#!/usr/bin/env bash
# Usage: launch-user.sh <username> <ssh_port> <display_num>
set -e
USERNAME="${1:?Usage: launch-user.sh <username> <ssh_port> <display_num>}"
SSH_PORT="${2:?SSH port required}"
DISPLAY_NUM="${3:?Display number required}"
export DISPLAY=":${DISPLAY_NUM}"
VNC_PORT=$((5900 + DISPLAY_NUM))
NOVNC_PORT=$((6080 + DISPLAY_NUM))
RESOLUTION="${RESOLUTION:-1920x1080x24}"

echo "==> $USERNAME: display $DISPLAY, ssh $SSH_PORT, vnc $VNC_PORT"

Xvfb "$DISPLAY" -screen 0 "$RESOLUTION" -ac +extension RANDR +extension GLX &
sleep 1
cinnamon-session &
sleep 3

mkdir -p "/home/$USERNAME/.vnc"
[ ! -f "/home/$USERNAME/.vnc/passwd" ] && x11vnc -storepasswd changeme "/home/$USERNAME/.vnc/passwd"
x11vnc -display "$DISPLAY" -forever -shared -rfbauth "/home/$USERNAME/.vnc/passwd" \
    -rfbport "$VNC_PORT" -quiet &
websockify --web /usr/share/novnc "$NOVNC_PORT" "localhost:$VNC_PORT" &
/usr/sbin/sshd -p "$SSH_PORT" -o "PidFile=/tmp/sshd-${USERNAME}.pid"

echo "==> $USERNAME ready: ssh -p $SSH_PORT $USERNAME@localhost | http://localhost:$NOVNC_PORT"
