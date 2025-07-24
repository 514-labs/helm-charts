# MDS Helm Chart

This Helm chart deploys the Moose Deployment Service (MDS) on a Kubernetes cluster.

## Overview

MDS is responsible for managing Moose deployments within the Kubernetes cluster. It handles:
- Namespace lifecycle management
- Deployment creation and management
- Resource provisioning
- Integration with external services (Redis, ClickHouse, Temporal, etc.)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- OpenTelemetry Operator (if using OpenTelemetry features)

## Installation

```bash
# Install the chart
helm upgrade -i mds-test ./mds -f ./mds/values-test.yaml --namespace boreal-system-testing --create-namespace
```

## Configuration

### Global Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `namespace` | Namespace to deploy MDS | `boreal-system` |
| `nameOverride` | Override the chart name | `""` |
| `fullnameOverride` | Override the full name | `""` |

### Deployment Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `deployment.environment` | Environment | `production` |
| `deployment.replicaCount` | Number of replicas | `2` |
| `deployment.image.repository` | Image repository | `us-central1-docker.pkg.dev/moose-hosting-node/hosting/mds` |
| `deployment.image.tag` | Image tag | `` |
| `deployment.image.pullPolicy` | Image pull policy | `Always` |

### Service Account and RBAC
| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.name` | Service account name | `mds` |

### Secrets Configuration
#### AWS Secrets
- `secrets.aws.name`: Name of AWS configuration secret (default: `sn-mds-aws-config`)

#### Redis Secrets
- `secrets.redis.name`: Production Redis secret (default: `sn-redis-config`)

#### Pulumi Secrets
- `secrets.pulumi.name`: Pulumi configuration secret (default: `sn-mds-pulumi-config`)

#### Other Service Secrets
- `secrets.temporal.name`: Temporal configuration (default: `sn-mds-temporal-config`)
- `secrets.redpanda.name`: Redpanda configuration (default: `sn-mds-redpanda-config`)
- `secrets.clickhouse.name`: ClickHouse configuration (default: `sn-mds-clickhouse-config`)

### OpenTelemetry Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `opentelemetry.enabled` | Enable OpenTelemetry collector | `true` |
| `opentelemetry.collector.image` | OTel collector image | `otel/opentelemetry-collector-contrib:0.126.0` |
| `opentelemetry.collector.mode` | Collector mode | `sidecar` |

### Resources

Configure resource requests:  
limits are specifically left out so that pods are not auto terminated.

```yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
```

## Monitoring

The chart includes OpenTelemetry instrumentation for:
- Distributed tracing
- Metrics collection

## Uninstallation

```bash
helm uninstall -n boreal-system-testing mds-test
```

## Testing

To test the chart in a separate namespace:

2. Install the chart with test values:
```bash
helm upgrade -i mds-test ./mds -f ./mds/values-test.yaml --namespace boreal-system-testing --create-namespace
```

3. Verify deployment:
```bash
kubectl get all -n boreal-system-testing
kubectl logs -n boreal-system-testing deployment/mds-test 
```

## Troubleshooting

### Check deployment status
```bash
kubectl get deployments -n boreal-system
```

### View logs
```bash
kubectl logs -n boreal-system deployment/mds
```

### Check RBAC permissions
```bash
kubectl auth can-i --list --as=system:serviceaccount:boreal-system:mds
``` 

# Generating Manifest Files for Manual Install
```bash
helm template mds-test ./mds -f ./mds/values-test.yaml
```