#!/bin/bash
set -euo pipefail

REPO_URL="${REPO_URL:-}"
BRANCH="${BRANCH:-main}"

cd /opt/app
if [ ! -d .git ]; then
  if [ -z "${REPO_URL}" ]; then
    echo "REPO_URL is empty and no .git dir exists" >&2
    exit 1
  fi
  git init
  git remote add origin "$REPO_URL" || git remote set-url origin "$REPO_URL"
  git fetch origin "$BRANCH"
  git checkout -B "$BRANCH" "origin/$BRANCH"
else
  if [ -n "${REPO_URL}" ]; then
    git remote set-url origin "$REPO_URL"
  fi
  git fetch origin "$BRANCH"
  git checkout "$BRANCH"
  git reset --hard "origin/$BRANCH"
fi

if [ -f requirements.txt ]; then
  . .venv/bin/activate
  pip install -r requirements.txt
fi

sudo systemctl restart app
echo "$(date -Is) Deployed branch=$BRANCH repo=${REPO_URL:-origin}" >> /var/log/deploy/deploy.log
