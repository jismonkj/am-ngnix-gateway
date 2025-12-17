#!/bin/sh
set -e

cd "$(dirname "$0")/.."

echo "[1/2] Building and starting all services (nginx + microservices + test-runner)..."
docker compose up --build -d

# Wait for containers to be healthy
sleep 5

echo "[2/2] Running health and routing tests..."
docker compose run --rm test-runner

status=$?
if [ $status -eq 0 ]; then
  echo "\nAll services healthy and routing OK."
else
  echo "\nSome tests failed. Check logs above."
fi
