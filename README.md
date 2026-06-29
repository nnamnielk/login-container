# login-container

Multi-user remote desktop environment — Docker containers with Cinnamon desktop, SSH, noVNC web access, and JupyterLab. Built for developer workspaces, AI agent sandboxes, and remote training labs.

## Architecture

```
                    ┌──────────────┐
                    │   Browser    │  noVNC (web desktop)
                    │  localhost    │
                    └──┬───┬───┬───┘
                       │   │   │
               ┌───────┘   │   └───────┐
               ▼           ▼           ▼
          ┌─────────┐ ┌─────────┐ ┌──────────┐
          │  Alice  │ │   Bob   │ │ Sunshine │
          │ :2201   │ │ :2202   │ │  (host)  │
          │  Cinnamon│ │  Cinnamon│ │  stream  │
          │  Jupyter │ │  Jupyter │ │          │
          └─────────┘ └─────────┘ └──────────┘
```

Each user gets an isolated container with:
- **Desktop**: Cinnamon DE via x11vnc + noVNC (browser-accessible)
- **Shell**: zsh + powerlevel10k + modern CLI tools (eza, bat, ripgrep)
- **SSH**: password or public-key auth on a dedicated port
- **JupyterLab**: token-free, root-dir scoped to user home
- **AI tools**: Hermes Agent + Codex CLI + Hermes WebUI (auto-installed on first boot)

Theming: Nordic-darker GTK theme + Papirus icons + solid Nord background (#2E3440).

## Quick Start

```bash
# Build the image
make build

# Start alice + bob
make up

# Full stack (includes Sunshine game streaming)
make up-full

# Open desktops in browser
make web-alice   # → http://localhost:6081/vnc.html
make web-bob     # → http://localhost:6082/vnc.html
```

## Access

| Service       | Alice              | Bob                |
|---------------|--------------------|--------------------|
| SSH           | `ssh -p 2201 alice@localhost` | `ssh -p 2202 bob@localhost` |
| noVNC (web)   | http://localhost:6081/vnc.html | http://localhost:6082/vnc.html |
| VNC (direct)  | localhost:5901     | localhost:5902     |
| JupyterLab    | http://localhost:8888 | http://localhost:8889 |
| **Hermes WebUI** | http://localhost:8787 | http://localhost:8788 |

Default password for all users: `changeme`

To inject an SSH public key, set the environment variable before starting:

```bash
SSH_PUBLIC_KEY="ssh-ed25519 AAAAC3..." docker compose up -d alice
```

Or add it to the `environment:` section in `docker-compose.yml`.

## Customization

### Adding Users

Copy the `alice` / `bob` service block in `docker-compose.yml`, change the name and port offsets. Each user needs unique SSH, VNC, noVNC, and Jupyter ports mapped on the host.

### Installing Hermes Agent

Edit `scripts/install-hermes.sh` with your actual install logic. By default it creates a stub in `/opt/hermes/`. Replace with:

```bash
git clone https://github.com/nous/hermes-agent.git /opt/hermes
cd /opt/hermes && pip install -e .
```

### Installing Codex Desktop

Edit `scripts/install-codex.sh`. The current stub creates a placeholder in `/opt/codex/` and a `.desktop` entry so it appears in the Cinnamon app menu once you drop in the real binary.

## Makefile

```make
make build       # docker compose build --no-cache
make up          # start alice + bob
make up-full     # start everything incl. sunshine
make down        # stop all containers
make clean       # stop + remove volumes + image
make shell-alice # zsh shell into alice's container
make shell-bob   # zsh shell into bob's container
make logs        # follow compose logs
```

## Requirements

- Docker Engine 24+ with Compose v2
- 4+ GB RAM (2 GB shm per container)
- GPU (optional, for Sunshine streaming)

## License

MIT
