#!/usr/bin/env bash
# ── Nordic ricing ─────────────────────────────────────────────────────
# GTK theme + icons
gsettings set org.cinnamon.desktop.interface gtk-theme 'Nordic-darker' 2>/dev/null || true
gsettings set org.cinnamon.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
gsettings set org.cinnamon.desktop.interface cursor-theme 'PAPIRUS' 2>/dev/null || true
gsettings set org.cinnamon.desktop.interface font-name 'Fira Code 10' 2>/dev/null || true

# wallpaper – solid dark with cinnamon default bg fallback
gsettings set org.cinnamon.desktop.background picture-uri '' 2>/dev/null || true
gsettings set org.cinnamon.desktop.background primary-color '#2E3440' 2>/dev/null || true
gsettings set org.cinnamon.desktop.background color-shading-type 'solid' 2>/dev/null || true

# terminal
gsettings set org.cinnamon.desktop.default-applications.terminal exec 'kitty' 2>/dev/null || true

# panel – dark
gsettings set org.cinnamon.theme name 'cinnamon' 2>/dev/null || true
gsettings set org.cinnamon panels-enabled "['1:0:bottom']" 2>/dev/null || true

echo "[ricing] nordic theme applied"
