# Hello World Birthday API Service

## Overview
A production-grade service to store and retrieve user birthdays, with full CI/CD, Kubernetes, and GitOps support. 

## Features
- FastAPI + SQLAlchemy + Pydantic
- PostgreSQL (CloudNativePG HA-ready)
- Flyway SQL migrations (Kubernetes Job, automated via Makefile)
- Dockerized, Kustomize-compatible Kubernetes manifests
- GitHub Actions CI/CD (lint, test, build, push)
- ArgoCD GitOps
- Makefile for common tasks
- Secure secret management (templates, .gitignore, K8s secrets)
- Prometheus/Grafana monitoring, ServiceMonitor/PodMonitor support

## Architecture
- See [docs/architecture.md](docs/architecture.md) for a detailed system diagram and explanation.
- App and DB are managed by separate manifests for safe, independent lifecycle management.
- Disaster Recovery (DR) / Replica Cluster: see `k8s/examples/replica-cluster.yaml`.

## Getting Started

### Prerequisites
- Python 3.12
- Docker
- kubectl
- minikube (for local Kubernetes)
- (Optional) AWS CLI and eksctl for EKS

## Local Development

You can deploy and destroy the stack on minikube using either the provided scripts or the Makefile targets:

### Deploying on minikube
```sh
make minikube-deploy
```
- This builds the Docker image, deploys the database and app, waits for readiness, and port-forwards the app to localhost:8000.
- Access your API at: http://localhost:8000
- See docs at: http://localhost:8000/docs

### Destroying the minikube stack
```sh
make minikube-destroy
```

## Usage
- `PUT /hello/<username>`: Set birthday (dateOfBirth: YYYY-MM-DD)
- `GET /hello/<username>`: Greet user, show days until birthday
- `GET /hello/healthz`: Health check endpoint
- `GET /`: Welcome message

## Configuration
- All configuration is via Kubernetes manifests.
- Database credentials and sensitive values are managed externally (Kubernetes Secrets or cloud secret manager).
- See [docs/observability.md](docs/observability.md) for monitoring setup and troubleshooting.
- See [docs/migrations.md](docs/migrations.md) for migration workflow.

## Contributing
Contributions are welcome! Please open issues or pull requests. See [docs/adr/](docs/adr/) for architecture decisions and guidelines.

## License
MIT License. See [LICENSE](LICENSE) for details.
