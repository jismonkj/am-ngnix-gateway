# am-ngnix-gateway

AM Nginx Gateway

## Purpose
- Lightweight nginx reverse proxy for routing to microservices in Docker or Kubernetes.

## Contents
- Dockerfile
- nginx/ (nginx configuration)
- docker-compose.yml (example with two test services)
- scripts/test-deploy.sh - Platform-independent test script (runs in Docker/K8s)
- scripts/test-deploy.env - Configurable endpoints for test script
- scripts/Dockerfile.test - Test runner image
- scripts/deploy.ps1 - (Optional) Build + start stack (Windows PowerShell)
- scripts/deploy-and-test.sh - All-in-one deploy and test script (recommended)
- k8s/ (Kubernetes manifests for gateway, services, config, and test runner)

## Quick start
### One-step deploy and test (Docker, recommended)
1. Open terminal in repository root.
2. Run: `./scripts/deploy-and-test.sh`
   - This will build and start all services, then run the health and routing tests automatically.
   - Results will be shown in your terminal.

### Manual Docker steps
1. Run: `docker compose up --build` (runs gateway, services, and test-runner)
   - Test results will appear in the logs for the `am-test-runner` container.
2. To re-run tests: `docker compose run --rm test-runner`

### Kubernetes deployment
1. Build and push images (`am-nginx-gateway:latest` and `am-test-runner:latest`) to a registry accessible by your cluster.
2. Edit the image fields in `k8s/gateway-deployment.yaml` and `k8s/test-runner-job.yaml` to use your registry URLs if needed.
3. Apply all manifests:
   ```sh
   kubectl apply -f k8s/nginx-configmap.yaml
   kubectl apply -f k8s/service1-deployment.yaml
   kubectl apply -f k8s/service2-deployment.yaml
   kubectl apply -f k8s/gateway-deployment.yaml
   kubectl apply -f k8s/test-runner-job.yaml
   ```
4. To check test results: `kubectl logs job/am-test-runner`
5. Gateway will be available on NodePort 30080 (or change as needed).

## Customizing
- Edit `nginx/conf.d/default.conf` to add or change routing rules.
- Add or replace services in `docker-compose.yml` or `k8s/*-deployment.yaml` and ensure the service names match upstream hosts in the config.
- Edit `scripts/test-deploy.env` (Docker) or environment in `k8s/test-runner-job.yaml` to change which endpoints are tested.

## Notes
- Gateway listens on container port 80 mapped to localhost:8080 (Docker) or NodePort 30080 (K8s).
- This setup uses hashicorp/http-echo as simple sample services; replace with real images as needed.
- The test-runner is platform-independent and runs in Docker or Kubernetes for consistent results.
- All configuration is hot-reloadable: just update the config and re-run the deploy script or re-apply manifests.