#!/bin/zsh
# deploy-minikube.sh: Deploy the full stack to minikube for local development
set -e

# Start minikube if not running
echo "[INFO] Checking minikube status..."
if ! minikube status | grep -q "host: Running"; then
  echo "[INFO] Starting minikube..."
  minikube start
fi

# Set Docker env for minikube and build image
echo "[INFO] Building Docker image in minikube..."
eval "$(minikube docker-env)"
docker build -t helloworld-birthday-api:latest .

echo "[INFO] Deploying CloudNativePG operator and cluster..."
# Deploy CloudNativePG operator and wait for it to be ready
kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.26/releases/cnpg-1.26.0.yaml

# Wait for CloudNativePG operator pod to be ready
echo "[INFO] Waiting for CloudNativePG operator pod to be ready..."
until kubectl get pods -n cnpg-system | grep 'cnpg-controller-manager' | grep -q 'Running'; do
  echo "[INFO] Waiting for cnpg-controller-manager pod..."; sleep 2;
done
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=cloudnative-pg -n cnpg-system --timeout=120s

# Deploy database and app (overlay includes base)
kubectl apply -k k8s/overlays/dev/

# Wait for DB pod(s) to be created before waiting for readiness
sleep 5
until kubectl get pods -l cnpg.io/cluster=hello-postgres | grep hello-postgres- | grep -v initdb; do
  echo "[INFO] Waiting for database pod(s) to be created..."; sleep 2;
done

# Wait for DB pod to be ready
# Only wait for main DB pods, not initdb jobs
for pod in $(kubectl get pods -l cnpg.io/cluster=hello-postgres -o name | grep hello-postgres- | grep -v initdb); do
  echo "[INFO] Waiting for $pod to be ready..."
  kubectl wait --for=condition=Ready $pod --timeout=120s
done

# Wait for app pod to be ready
echo "[INFO] Waiting for app pod to be ready..."
kubectl wait --for=condition=Ready pod -l app=hello-api --timeout=120s

# Port-forward the service for local access
echo "[INFO] Port-forwarding service hello-api:8000 to localhost:8000..."
kubectl port-forward svc/hello-api 8000:8000 &
PORT_FORWARD_PID=$!

# Wait a moment for port-forward to be ready
sleep 3

# Print access info
echo "[SUCCESS] App deployed!"
echo "Access your API at: http://localhost:8000/hello/healthz"
echo "Or see docs at: http://localhost:8000/docs"
echo "(Press Ctrl+C to stop port-forwarding when done)"

# Wait for user to stop script
wait $PORT_FORWARD_PID
