#!/bin/bash
set -euo pipefail

APP_DIR=/opt/app
BRANCH=${BRANCH:-lab_4}
REPO_URL=${REPO_URL:-https://github.com/exxxpm/DevOPS_labs.git}

cd "$APP_DIR"

# Обновляем код
if [ ! -d .git ]; then
  git init
  git remote add origin "$REPO_URL" || git remote set-url origin "$REPO_URL"
fi

git fetch origin "$BRANCH"
git checkout -B "$BRANCH" "origin/$BRANCH"
git reset --hard "origin/$BRANCH"

# Обновляем контейнеры из registry (без локального build)
docker compose pull
docker compose up -d

echo "$(date -Is) lab4 deployed from branch=$BRANCH" >> /var/log/deploy/lab4-deploy.log
