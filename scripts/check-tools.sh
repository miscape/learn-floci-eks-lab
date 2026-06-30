#!/usr/bin/env bash
set -euo pipefail

check() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "[OK] $1 -> $(command -v "$1")"
  else
    echo "[MISSING] $1"
  fi
}

check git
check docker
check aws
check kubectl

echo
echo "Docker version:"
docker --version || true

echo
echo "Docker Compose version:"
docker compose version || true

echo
echo "AWS CLI version:"
aws --version || true

echo
echo "kubectl version:"
kubectl version --client || true

