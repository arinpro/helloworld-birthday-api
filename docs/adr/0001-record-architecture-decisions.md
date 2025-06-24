# 0001 Record architecture decisions

Date: 2025-06-24

## Context
This project implements a production-grade birthday API service, designed for cloud-native, GitOps-managed environments. It leverages FastAPI, SQLAlchemy, Pydantic, PostgreSQL (CloudNativePG), Flyway for migrations, Docker, Kubernetes, ArgoCD for GitOps, and GitHub Actions for CI/CD. The architecture emphasizes best practices in security, automation, disaster recovery, and maintainability. All significant architectural and technical decisions will be documented and version-controlled in the `adr/` directory.

### Key Decisions for this Project
- **API Framework:** Use FastAPI for its async support, OpenAPI integration, and developer productivity.
- **ORM & Validation:** Use SQLAlchemy for database ORM and Pydantic for data validation and serialization.
- **Database:** Use CloudNativePG for a self-managed, Kubernetes-native HA PostgreSQL setup.
- **Database Migrations:** Use Flyway for versioned, repeatable, and automated schema migrations, executed as Kubernetes Jobs.
- **Containerization:** Use Docker for consistent, portable application packaging.
- **Kubernetes Manifests:** Use Kustomize for environment overlays and manifest composition.
- **GitOps:** Use ArgoCD for declarative, automated deployment and drift detection. Use ArgoCD Image Updater for automated image tag updates.
- **CI/CD:** Use GitHub Actions for linting, testing, building, and publishing Docker images to GHCR. Enforce CI validation of migrations and tests.
- **Secret Management:** Use Kubernetes Secrets, with all secret manifests templated and real secrets gitignored. Use CloudNativePG-generated secrets for DB access.
- **Separation of Concerns:** Manage application and database lifecycle with separate manifests for safe, independent upgrades and rollbacks.
- **Disaster Recovery:** Provide a documented, example CloudNativePG replica cluster manifest for DR scenarios, leveraging WAL archiving to S3-compatible storage.
- **Testing:** Use pytest for unit and integration tests, supporting both local and in-cluster PostgreSQL. Auto-create/drop schema for test isolation.
- **Observability:** Use Prometheus, Grafana, and Alertmanager for monitoring, alerting, and visualization; expose FastAPI metrics at `/metrics` and provide K8s probes. See `docs/observability.md` for details.
- **Documentation:** All operational and architectural documentation is version-controlled in `docs/`. Maintain ADRs and example manifests for operational clarity.