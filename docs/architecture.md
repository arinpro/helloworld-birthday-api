# System Architecture

This document provides a detailed view of the system architecture for the Hello World Birthday API Service.

## Architecture Diagram (AWS Example)

```mermaid
flowchart TD
    %% === User Zone ===
    subgraph UserZone
        User["User / API Client"]
    end

    %% === Load Balancer ===
    subgraph LoadBalancer
        LB["AWS ALB"]
    end

    %% === Primary Cluster ===
    subgraph PrimaryCluster["EKS Cluster #1 (Primary)"]
        ArgoCD["ArgoCD (GitOps)"]
        App["FastAPI Birthday API"]
        SVC["K8s Service"]
        PG["CloudNativePG Primary Cluster"]
        Primary1["Primary Node"]
        Standby1["Standby Node"]
        Standby2["Standby Node"]
        Prometheus1["Prometheus"]
    end

    %% === Replica Cluster ===
    subgraph ReplicaCluster["EKS Cluster #2 (Replica / DR)"]
        PGReplica["CloudNativePG Replica Cluster"]
        DRPrimary1["Designated Primary"]
        DRStandby1["Standby Node"]
        DRStandby2["Standby Node"]
        Prometheus2["Prometheus"]
    end

    %% === Git Infrastructure ===
    subgraph GitInfra["GitHub + CI/CD"]
        Git["GitHub Repo"]
        CI["GitHub Actions"]
        GHCR["GitHub Container Registry"]
    end

    %% === Observability ===
    subgraph Observability["Monitoring & Visualization"]
        Grafana["Grafana Dashboard"]
    end

    %% === Backup Store ===
    subgraph Backup["Backup Object Store"]
        S3["S3 (WAL Archive + Backups)"]
    end

    %% === Flow Connections ===
    %% User Access
    User --> LB
    LB --> SVC
    SVC --> App
    App --> PG

    %% GitOps Flow
    ArgoCD --> Git
    ArgoCD --> GHCR
    ArgoCD --> App
    CI --> Git
    CI --> GHCR

    %% Primary DB Cluster
    PG --> Primary1
    PG --> Standby1
    PG --> Standby2
    PG --> S3
    PG --> Prometheus1

    %% App Metrics
    App --> Prometheus1

    %% Replica DB Cluster
    S3 --> PGReplica
    PGReplica --> DRPrimary1
    PGReplica --> DRStandby1
    PGReplica --> DRStandby2
    PGReplica --> Prometheus2

    %% Observability
    Prometheus1 --> Grafana
    Prometheus2 --> Grafana

    %% === Styling ===
    style PG fill:#cce5ff,stroke:#004085,stroke-width:1.5px,stroke-dasharray: 5 1
    style PGReplica fill:#d6e9f8,stroke:#005c99,stroke-width:1.5px,stroke-dasharray: 5 1
    style S3 fill:#ffe0b3,stroke:#d35400,stroke-width:1.5px
    style Prometheus1 fill:#e5ccff,stroke:#6f42c1,stroke-width:1.5px
    style Prometheus2 fill:#e5ccff,stroke:#6f42c1,stroke-width:1.5px
    style Grafana fill:#fff3b3,stroke:#ffc107,stroke-width:1.5px
    style ArgoCD fill:#e0e0e0,stroke:#666
    style App fill:#d4edda,stroke:#155724
    style GHCR fill:#f0f0f0,stroke:#333
    style CI fill:#f0f0f0,stroke:#333
    style Git fill:#f0f0f0,stroke:#333
```

## Description
- Users access the API via AWS Load Balancer, routed to the FastAPI app running in EKS.
- ArgoCD manages deployments from GitHub (GitOps) and updates images from GHCR.
- CloudNativePG provides HA PostgreSQL inside the cluster, with S3 for backups and supports a second DR region (replica cluster) for disaster recovery and business continuity.
- CI/CD pipeline builds, tests, and pushes images to GHCR.
- Monitoring and observability are fully integrated using Prometheus and Grafana, with ServiceMonitor and PodMonitor resources for automated metrics scraping from both the app and database.
