#!/bin/zsh
# destroy-minikube.sh: Tear down all resources deployed by deploy-minikube.sh
set -e

# Delete app and database resources (overlay includes base)
echo "[INFO] Deleting app and database resources..."
kubectl delete -k k8s/overlays/dev/ --ignore-not-found

# Delete CloudNativePG operator
echo "[INFO] Deleting CloudNativePG operator..."
kubectl delete --ignore-not-found -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.26/releases/cnpg-1.26.0.yaml

# Optionally stop minikube (uncomment if desired)
# echo "[INFO] Stopping minikube..."
# minikube stop

echo "[SUCCESS] All resources deleted."
