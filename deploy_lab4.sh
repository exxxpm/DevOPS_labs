#!/bin/bash
set -euo pipefail

APP_DIR=/opt/app

cd "$APP_DIR"

export DOCKER_CLIENT_TIMEOUT=300
export COMPOSE_HTTP_TIMEOUT=300

echo "==== [lab4] docker compose pull (with retries) ===="
for i in 1 2 3; do
    if docker compose pull; then
        echo "Pull succeeded on attempt $i"
        break
    fi
    echo "Pull failed on attempt $i, retrying in 20s..."
    sleep 20
    if [ "$i" -eq 3 ]; then
        echo "Pull failed after 3 attempts, aborting"
        exit 1
    fi
done

echo "==== [lab4] restarting stack ===="
# убираем всё старое по именам, на случай «висячих» контейнеров
docker rm -f lab4-web lab4-db 2>/dev/null || true

# а затем стандартный down/up для текущего compose-проекта
docker compose down || true
docker compose up -d --remove-orphans

echo "$(date -Is) lab4 deployed via compose" >> /var/log/deploy/lab4-deploy.log
