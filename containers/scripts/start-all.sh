#!/usr/bin/env bash
echo "==> Starting D-Bus system daemon..."
mkdir -p /run/dbus
dbus-daemon --system --fork 2>/dev/null || true
sleep 1

echo "==> Starting Alice (ssh:2201, vnc:5910, novnc:6090)..."
/usr/local/bin/launch-user.sh alice 2201 10 &
sleep 4

echo "==> Starting Bob (ssh:2202, vnc:5911, novnc:6091)..."
/usr/local/bin/launch-user.sh bob 2202 11 &
sleep 4

echo "==> All services started!"
echo "  Alice SSH: ssh -p 2201 alice@localhost"
echo "  Bob SSH:   ssh -p 2202 bob@localhost"
echo "  Alice Web: http://localhost:6090"
echo "  Bob Web:   http://localhost:6091"
