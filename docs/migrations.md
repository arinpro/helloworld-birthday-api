# Migration Workflow

This document describes the migration workflow for the Hello World Birthday API Service using Flyway and Kubernetes.

## Development & CI
- Migrations are validated in CI (GitHub Actions) for correctness.
- You can run Flyway locally for development/testing if needed.

## Production (Kubernetes)
- Migrations are applied in-cluster using a Kubernetes Job.
- Use the Makefile to:
  - Generate/update Flyway ConfigMaps:
    ```sh
    make flyway-cm
    ```
  - Run the migration job:
    ```sh
    make migrate
    ```
- The migration job will apply all pending migrations and exit.

## ConfigMap Management
- Flyway config and SQL migration files are stored in ConfigMaps, generated from local files.
- Always update ConfigMaps before running the migration job.
