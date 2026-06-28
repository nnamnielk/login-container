#!/usr/bin/env bash
# ── Codex Desktop installer ──────────────────────────────────────────
# Override this script to install your Codex Desktop into /opt/codex
set -e

CODEX_DIR="${CODEX_DIR:-/opt/codex}"
USERNAME="${1:-user}"

echo "==> installing Codex Desktop into $CODEX_DIR"

mkdir -p "$CODEX_DIR"

# ── placeholder: replace with your actual install ───────────────────
# Example — download a release:
#   curl -fsSL "https://releases.your-org.com/codex-desktop-latest.AppImage" \
#       -o "$CODEX_DIR/codex-desktop.AppImage"
#   chmod +x "$CODEX_DIR/codex-desktop.AppImage"

# Desktop entry so it shows up in Cinnamon menu
mkdir -p "/usr/share/applications"
cat > "/usr/share/applications/codex-desktop.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Codex Desktop
Comment=Codex Desktop IDE
Exec=/opt/codex/codex-desktop
Icon=/opt/codex/icon.png
Terminal=false
Categories=Development;IDE;
EOF

cat > "$CODEX_DIR/README.txt" <<'EOF'
Codex Desktop — stub
Replace scripts/install-codex.sh with your actual installer.
Expected layout:
  /opt/codex/
    codex-desktop   # main binary/entrypoint
    icon.png        # application icon
EOF

chown -R "$USERNAME:$USERNAME" "$CODEX_DIR" 2>/dev/null || true
echo "[codex] installed (stub)"
