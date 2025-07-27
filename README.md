# 514 Labs Helm Charts Repository

This repository contains the official Helm charts for 514 Labs. It serves as a mono-repo for all public Helm charts and hosts packaged charts via GitHub Pages.

## Repository Structure

```
helm-charts/
├── charts/           # Source code for all charts
│   └── mds/         # Moose Deployment Service chart
├── packages/        # Packaged charts (.tgz files) - ignored in git
├── scripts/         # Helper scripts for chart management
├── index.yaml       # Helm repository index file
└── README.md        # This file
```

## Using This Repository

### Adding the Repository

To add this repository to your Helm client:

```bash
helm repo add 514labs https://514-labs.github.io/helm-charts/
helm repo update
```

### Searching for Charts

To search for available charts:

```bash
helm search repo 514labs
```

### Installing Charts

To install a chart from this repository:

```bash
# Install the latest version
helm install my-release 514labs/mds

# Install a specific version
helm install my-release 514labs/mds --version 0.1.0

# Install with custom values
helm install my-release 514labs/mds -f my-values.yaml
```

## For Chart Developers

### Prerequisites

- Helm 3.x installed
- Git
- Access to this repository

### Adding a New Chart

1. Create your chart in the `charts/` directory:
   ```bash
   helm create charts/my-new-chart
   ```

2. Develop and test your chart:
   ```bash
   helm lint charts/my-new-chart
   helm template charts/my-new-chart
   ```

3. Update the chart version in `Chart.yaml` when ready to release

4. Package the chart and update the repository index:
   ```bash
   ./scripts/package-charts.sh
   ```

5. Commit your changes and create a pull request

### Updating an Existing Chart

1. Make your changes to the chart in the `charts/` directory
2. Bump the version in the chart's `Chart.yaml` file (following semantic versioning)
3. Test your changes thoroughly
4. Run the packaging script to generate the new package
5. Commit and create a pull request

### Manual Chart Packaging

If you need to package charts manually:

```bash
# Package a specific chart
helm package charts/mds -d packages/

# Update the repository index
helm repo index . --url https://514-labs.github.io/helm-charts/
```

## Available Charts

| Chart | Description | Latest Version |
|-------|-------------|----------------|
| mds | Moose Deployment Service - manages Moose deployments in Kubernetes | 0.1.0 |

## Chart Documentation

Each chart has its own README with detailed documentation:

- [MDS Chart](charts/mds/README.md) - Moose Deployment Service

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Chart Standards

All charts in this repository should follow these standards:

- Include a comprehensive `README.md`
- Follow Helm best practices
- Include proper labels and annotations
- Support multiple deployment scenarios (dev/staging/prod)
- Include health checks and probes where applicable
- Document all configurable values in `values.yaml`

## GitHub Actions

This repository uses GitHub Actions for:

- Linting and validating charts on pull requests
- Automatically packaging and publishing charts on merge to main
- Updating the GitHub Pages site with new chart versions

## Support

For issues and questions:

- Check the chart-specific README files
- Open an issue in this repository
- Contact the 514 Labs team at support@514labs.com

## License

This repository and all charts are proprietary to 514 Labs unless otherwise specified in individual chart directories.
