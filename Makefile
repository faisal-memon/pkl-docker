PKL ?= pkl
OUT ?= out
VERSION ?= 0.1.0
NGINX_COMPOSE ?= $(OUT)/nginx.yaml
NGINX_PROJECT ?= pkl-docker-nginx

.PHONY: render render-nginx validate package integration-up integration-test integration-down
render:
	@mkdir -p "$(OUT)"
	@$(PKL) eval -o "$(OUT)/nginx.yaml" examples/nginx.pkl

validate: render
	@$(PKL) eval examples/nginx.pkl >/dev/null
	@echo "pkl-docker validation succeeded."

render-nginx:
	@mkdir -p "$(OUT)"
	@$(PKL) eval -o "$(NGINX_COMPOSE)" examples/nginx.pkl

integration-up: render-nginx
	@docker compose -p "$(NGINX_PROJECT)" -f "$(NGINX_COMPOSE)" up -d

integration-down:
	@docker compose -p "$(NGINX_PROJECT)" -f "$(NGINX_COMPOSE)" down --remove-orphans || true

integration-test: render-nginx
	@set -eu; trap '$(MAKE) integration-down' EXIT; \
		docker compose -p "$(NGINX_PROJECT)" -f "$(NGINX_COMPOSE)" up -d; \
		for attempt in $$(seq 1 30); do \
			if curl --fail --silent http://127.0.0.1:18080/ | grep -q "Welcome to nginx"; then \
				echo "Nginx integration test passed."; exit 0; \
			fi; \
			sleep 1; \
		done; \
		echo "Nginx did not become ready." >&2; \
		docker compose -p "$(NGINX_PROJECT)" -f "$(NGINX_COMPOSE)" logs; exit 1

package:
	@PKL_PACKAGE_VERSION="$(VERSION)" $(PKL) project package --output-path dist
