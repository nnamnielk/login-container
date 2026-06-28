.PHONY: build up down clean shell-alice shell-bob logs

IMAGE   := ubuntu-riced:latest
COMPOSE := docker compose

build:
	$(COMPOSE) build --no-cache

up:
	$(COMPOSE) up -d alice bob

up-full:
	$(COMPOSE) --profile full up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v
	docker rmi $(IMAGE) 2>/dev/null || true

shell-alice:
	docker exec -it user-alice zsh

shell-bob:
	docker exec -it user-bob zsh

ssh-alice:
	ssh -p 2201 alice@localhost

ssh-bob:
	ssh -p 2202 bob@localhost

logs:
	$(COMPOSE) logs -f

# ── open in browser ──────────────────────────────────────────────────
web-alice:
	@echo "→ http://localhost:6081/vnc.html"

web-bob:
	@echo "→ http://localhost:6082/vnc.html"
