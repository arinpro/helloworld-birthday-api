# Observability Guide

This document describes how to enable and use observability features for the Hello World Birthday API Service in Kubernetes environments.

## Application Metrics (Prometheus)

### FastAPI Instrumentation
- The app uses [prometheus-fastapi-instrumentator](https://github.com/trallnag/prometheus-fastapi-instrumentator) to expose metrics at `/metrics`.
- Prometheus can scrape these metrics for monitoring and alerting.

### Enabling Prometheus in Kubernetes
1. **Install Prometheus and Grafana** (recommended: kube-prometheus-stack via Helm, with CloudNativePG config):
   ```sh
   helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts

   helm upgrade --install \
   -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/docs/src/samples/monitoring/kube-stack-config.yaml \
   prometheus-community \
   prometheus-community/kube-prometheus-stack
   ```
2. **Configure Prometheus to scrape your app:**
   - The `ServiceMonitor` manifest for the `hello-api` service is included in `k8s/base/servicemonitor.yaml` and is applied by default.
3. **Configure Prometheus to scrape CloudNativePG metrics:**
   - If you set `monitoring: enablePodMonitor: true` in your CloudNativePG cluster manifest, a PodMonitor will be created automatically for Prometheus Operator to discover and scrape PostgreSQL metrics.
   - You do not need to manually create a ServiceMonitor or PodMonitor for CloudNativePG if this option is enabled.
   - See the cluster manifests in `k8s/overlays/dev/cluster.yaml`, `k8s/overlays/prod/cluster.yaml`, and `k8s/examples/replica-cluster.yaml` for reference.

   - > **Note:** For the CloudNativePG operator to automatically create a PodMonitor for your PostgreSQL cluster, the Prometheus Operator (and its PodMonitor CRD) must be installed **before** the CloudNativePG cluster is created. If the CRD is not present at cluster creation time, the PodMonitor will not be created automatically.

   - If you install or upgrade the Prometheus stack after your CloudNativePG cluster already exists, you can force the operator to create the PodMonitor by annotating the cluster to trigger a reconcile:

```sh
kubectl annotate cluster hello-postgres cnpg.io/force-reconcile=$(date +%s)
```

4. **View metrics in Grafana:**
   - Grafana is included in the kube-prometheus-stack Helm chart.
   - To access Grafana, port-forward the service:
     ```sh
     kubectl port-forward svc/prometheus-grafana 3000:80 -n default
     ```
     (If installed in a different namespace, adjust the namespace accordingly.)
   - Open [http://localhost:3000](http://localhost:3000) in your browser.
   - Default login: `admin/prom-operator` (or check the generated password with `kubectl get secret prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode`)
   - Import dashboards or create your own for FastAPI and PostgreSQL metrics.
     - Example steps to import a dashboard:
       1. In Grafana, click the "+" icon in the sidebar and select **Import**.
       2. You can:
          - Paste a dashboard ID from [Grafana.com Dashboards](https://grafana.com/grafana/dashboards/), or
          - Upload a JSON file if you have a custom dashboard.
       3. Select the Prometheus data source when prompted.
       4. Click **Import** to finish.

## Application Logging
- The app uses Python's `logging` module.
- For production, consider structured logging (e.g., JSON) and forwarding logs to a centralized system (e.g., Loki, ELK, or CloudWatch).

## Tracing (Optional)
- For distributed tracing, add [OpenTelemetry](https://opentelemetry.io/docs/instrumentation/python/) to your FastAPI app and deploy Jaeger or Tempo in your cluster.

## Health Checks
- Liveness/readiness probes are configured via `/hello/healthz`.

## Alerting
- Configure Prometheus Alertmanager for alerts on pod restarts, high error rates, or database issues.
