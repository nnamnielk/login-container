FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    RESOLUTION=1920x1080x24 \
    VNC_PORT=5901 \
    NOVNC_PORT=6080 \
    SSH_PORT=22 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# ── base system + cinnamon desktop ──────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    # locales & timezone
    locales tzdata sudo curl wget gpg software-properties-common \
    # cinnamon desktop
    cinnamon-desktop-environment \
    # display + vnc
    xvfb x11vnc x11-xserver-utils x11-utils \
    # web vnc client
    novnc websockify \
    # ssh
    openssh-server \
    # window manager extras
    dbus-x11 xdg-utils xdg-user-dirs \
    # audio
    pulseaudio pulseaudio-utils \
    # fonts + theming
    fonts-noto-color-emoji fonts-firacode \
    # ricing: gtk theme + icons
    arc-theme papirus-icon-theme \
    # terminal + shell niceties
    kitty zsh git unzip \
    # jupyterlab
    jupyter-notebook python3-pip python3-dev \
    # useful tools
    htop neofetch bat eza fd-find ripgrep nano vim \
    # build essentials (for hermes/codex)
    build-essential pkg-config libssl-dev \
    # cleanup
    && locale-gen en_US.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ── oh-my-zsh + powerlevel10k (riced shell) ────────────────────────────
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && chsh -s /usr/bin/zsh root

# ── jupyterlab + data science stack ────────────────────────────────────
RUN pip3 install --break-system-packages \
    jupyterlab \
    numpy pandas matplotlib seaborn scipy \
    && jupyter lab --generate-config \
    && echo 'c.ServerApp.ip = "0.0.0.0"' >> /root/.jupyter/jupyter_lab_config.py \
    && echo 'c.ServerApp.port = 8888' >> /root/.jupyter/jupyter_lab_config.py \
    && echo 'c.IdentityProvider.token = ""' >> /root/.jupyter/jupyter_lab_config.py \
    && echo 'c.ServerApp.allow_root = True' >> /root/.jupyter/jupyter_lab_config.py \
    && echo 'c.ServerApp.root_dir = "/home"' >> /root/.jupyter/jupyter_lab_config.py

# ── nordic gtk theme ───────────────────────────────────────────────────
RUN git clone --depth=1 https://github.com/EliverLara/Nordic.git /usr/share/themes/Nordic \
    && git clone --depth=1 https://github.com/EliverLara/Nordic.git /usr/share/themes/Nordic-darker

# ── copy configs ───────────────────────────────────────────────────────
COPY config/desktop/autostart/ /root/.config/autostart/
COPY config/desktop/gtk-3.0/ /root/.config/gtk-3.0/
COPY config/zshrc /root/.zshrc
COPY config/ssh/sshd_config /etc/ssh/sshd_config.d/custom.conf
COPY config/entrypoint/ /entrypoint/
COPY scripts/ /usr/local/bin/

RUN chmod +x /entrypoint/*.sh /usr/local/bin/*.sh 2>/dev/null; \
    # ssh setup
    mkdir -p /run/sshd && chmod 0755 /run/sshd; \
    # vnc password (changeme)
    mkdir -p /root/.vnc && x11vnc -storepasswd changeme /root/.vnc/passwd; \
    # gtk settings
    mkdir -p /root/.config/gtk-4.0

# ── gtk4 settings ──────────────────────────────────────────────────────
COPY <<'GTK4' /root/.config/gtk-4.0/settings.ini
[Settings]
gtk-theme-name=Nordic-darker
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Fira Code 10
GTK4

# ── ports ──────────────────────────────────────────────────────────────
EXPOSE 5901 6080 22 8888

ENTRYPOINT ["/entrypoint/entrypoint.sh"]
