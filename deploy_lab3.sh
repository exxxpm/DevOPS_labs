#!/bin/bash
set -euo pipefail

APP_DIR=/opt/app
BRANCH=${BRANCH:-lab_3}
REPO_URL=${REPO_URL:-https://github.com/exxxpm/DevOPS_labs.git}

cd "$APP_DIR"

if [ ! -d .git ]; then
  git init
  git remote add origin "$REPO_URL" || git remote set-url origin "$REPO_URL"
fi

git fetch origin "$BRANCH"
git checkout -B "$BRANCH" "origin/$BRANCH"
git reset --hard "origin/$BRANCH"

# собрать образ локально
docker build -t devops-lab3:"$BRANCH" .

# снести любые старые контейнеры, которые могут держать порт 8181
docker rm -f devops-lab3 devops-app 2>/dev/null || true

# запустить новый контейнер
docker run -d --name devops-lab3 \
  -p 8181:8181 \
  devops-lab3:"$BRANCH"

echo "$(date -Is) lab3 deployed from branch=$BRANCH" >> /var/log/deploy/lab3-deploy.log
