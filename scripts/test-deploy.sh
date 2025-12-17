#!/bin/sh
set -e

# Load endpoints from env file if present
if [ -f /scripts/test-deploy.env ]; then
  . /scripts/test-deploy.env
fi

GATEWAY_URL=${GATEWAY_URL:-http://gateway:80/health}
SERVICE1_URL=${SERVICE1_URL:-http://gateway:80/api/service1/}
SERVICE2_URL=${SERVICE2_URL:-http://gateway:80/api/service2/}

wait_for() {
  url="$1"
  name="$2"
  echo "Testing $name at $url ..."
  for i in $(seq 1 10); do
    res=$(curl -s --max-time 3 "$url" || true)
    if [ -n "$res" ]; then
      echo "$res"
      return 0
    fi
    echo "res: $res"
    sleep 10
  done
  echo "ERROR: $name not responding at $url" >&2
  exit 1
}

echo "Waiting for services to be ready..."
sleep 3

# Wait for gateway health endpoint
wait_for "$GATEWAY_URL" "gateway health"
health=$(curl -s --max-time 3 "$GATEWAY_URL" || true)
if [ "$health" = "ok" ]; then
  echo "Gateway health check OK"
else
  echo "Gateway health check failed: $health" >&2
  exit 1
fi

# Wait for service1
wait_for "$SERVICE1_URL" "service1"
svc1=$(curl -s --max-time 3 "$SERVICE1_URL" || true)
echo "$svc1" | grep -qi service1 && echo "Routing to service1 OK" || { echo "service1 unexpected response: $svc1" >&2; exit 1; }

# Wait for service2
wait_for "$SERVICE2_URL" "service2"
svc2=$(curl -s --max-time 3 "$SERVICE2_URL" || true)
echo "$svc2" | grep -qi service2 && echo "Routing to service2 OK" || { echo "service2 unexpected response: $svc2" >&2; exit 1; }

echo "All tests passed."
