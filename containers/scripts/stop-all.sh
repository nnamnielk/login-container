#!/usr/bin/env bash
echo "==> Stopping all services..."
pkill -f "Xvfb" 2>/dev/null || true
pkill -f "cinnamon-session" 2>/dev/null || true
pkill -f "x11vnc" 2>/dev/null || true
pkill -f "websockify" 2>/dev/null || true
pkill -f "sshd.*-p 220[12]" 2>/dev/null || true
pkill -f "dbus-daemon.*system" 2>/dev/null || true
echo "==> All services stopped"
