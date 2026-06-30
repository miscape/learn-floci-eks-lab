.PHONY: help check up down logs ps env aws-test clean

help:
	@echo "Available targets:"
	@echo "  make check     - Check local tools"
	@echo "  make up        - Start Floci"
	@echo "  make down      - Stop Floci"
	@echo "  make logs      - Show Floci logs"
	@echo "  make ps        - Show running containers"
	@echo "  make aws-test  - Test AWS CLI against Floci"
	@echo "  make clean     - Stop Floci and remove local runtime data"

check:
	./scripts/check-tools.sh

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f floci

ps:
	docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

aws-test:
	. ./scripts/env.sh && aws sts get-caller-identity --endpoint-url $$AWS_ENDPOINT_URL

clean:
	docker compose down -v
	rm -rf data
