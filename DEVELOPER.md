# Developer Guide

This guide provides detailed instructions for developers working with the 514 Labs Helm Charts repository.

## Repository Structure

```
.
├── charts/                 # Source code for all Helm charts
│   └── mds/               # Example: MDS chart
│       ├── Chart.yaml     # Chart metadata
│       ├── values.yaml    # Default values
│       ├── templates/     # Kubernetes templates
│       └── README.md      # Chart documentation
├── packages/              # Packaged charts (.tgz) - git ignored
├── scripts/               # Helper scripts
│   ├── package-charts.sh  # Package all charts
│   ├── publish-charts.sh  # Publish to gh-pages
│   └── test-repo.sh       # Test repository locally
├── .github/               # GitHub Actions workflows
│   └── workflows/
│       ├── lint-test.yaml # PR validation
│       └── release.yaml   # Auto-release on merge
├── index.yaml             # Repository index (git ignored)
└── README.md              # Public documentation
```

## Development Workflow

### 1. Setting Up Your Environment

```bash
# Clone the repository
git clone https://github.com/514-labs/helm-charts.git
cd helm-charts

# Ensure you have Helm 3.x installed
helm version

# Install pre-commit hooks (optional but recommended)
# This helps ensure consistent formatting and catch issues early
```

### 2. Creating a New Chart

```bash
# Create a new chart using Helm
helm create charts/my-new-chart

# Edit the chart
cd charts/my-new-chart

# Update Chart.yaml with appropriate metadata
# - name: Your chart name
# - version: Start with 0.1.0
# - description: Clear description
# - home: Project URL
# - maintainers: Your contact info

# Develop your templates in templates/
# Document configuration in values.yaml
# Write comprehensive README.md
```

### 3. Testing Your Chart

```bash
# Lint your chart
helm lint charts/my-new-chart

# Test template rendering
helm template test-release charts/my-new-chart

# Test with custom values
helm template test-release charts/my-new-chart -f test-values.yaml

# Dry run installation
helm install test-release charts/my-new-chart --dry-run --debug

# Install locally for testing (requires local Kubernetes)
helm install test-release charts/my-new-chart
```

### 4. Versioning

Follow semantic versioning (semver):
- MAJOR version for incompatible changes
- MINOR version for new features (backwards compatible)
- PATCH version for bug fixes

Always update the version in `Chart.yaml` when making changes.

### 5. Package and Test Repository

```bash
# Package all charts and generate index.yaml
./scripts/package-charts.sh

# Test the repository locally
./scripts/test-repo.sh

# In another terminal, test adding the local repo
helm repo add local-test http://localhost:8080
helm repo update
helm search repo local-test
```

### 6. Publishing Charts

#### Manual Publishing (for testing)

```bash
# Package charts
./scripts/package-charts.sh

# Publish to gh-pages branch
./scripts/publish-charts.sh
```

#### Automatic Publishing

Charts are automatically published when PRs are merged to main:
1. Create a feature branch
2. Make your changes
3. Create a pull request
4. GitHub Actions will validate your changes
5. Once merged, charts are automatically published

## Best Practices

### Chart Development

1. **Always use `.Values`** - Never hardcode values in templates
2. **Add comments** - Document complex logic in templates
3. **Use helpers** - Create reusable template functions in `_helpers.tpl`
4. **Include health checks** - Add readiness/liveness probes
5. **Support multiple scenarios** - Dev, staging, production configs
6. **Version dependencies** - Pin specific versions of dependencies

### Testing

1. **Test all scenarios** - Use different values files for different environments
2. **Validate YAML** - Ensure generated manifests are valid
3. **Check resource limits** - Always set resource requests/limits
4. **Test upgrades** - Ensure smooth upgrades from previous versions

### Documentation

1. **README.md is required** - Every chart must have comprehensive docs
2. **Document all values** - Explain every configurable value
3. **Provide examples** - Include example values files
4. **List prerequisites** - Document any requirements
5. **Include troubleshooting** - Common issues and solutions

## Common Tasks

### Updating an Existing Chart

```bash
# 1. Make your changes
vim charts/mds/templates/deployment.yaml

# 2. Bump the version
# Edit charts/mds/Chart.yaml and increment version

# 3. Test your changes
helm lint charts/mds
helm template test charts/mds

# 4. Package and test
./scripts/package-charts.sh

# 5. Commit and push
git add .
git commit -m "feat(mds): add new feature"
git push origin feature-branch
```

### Testing Chart Upgrades

```bash
# Install current version
helm install test-release charts/mds

# Make changes and bump version

# Test upgrade
helm upgrade test-release charts/mds

# Check rollback works
helm rollback test-release 1
```

### Debugging Templates

```bash
# See what values are available
helm template test charts/mds --debug

# Test specific values
echo "replicaCount: 5" > test-values.yaml
helm template test charts/mds -f test-values.yaml

# Check generated YAML
helm template test charts/mds | kubectl apply --dry-run=client -f -
```

## Troubleshooting

### Linting Errors

- **Missing required values**: Ensure all required values have defaults or clear error messages
- **Invalid YAML**: Check template syntax, especially around conditionals
- **Missing end tags**: Ensure all `{{- if }}` have corresponding `{{- end }}`

### Packaging Errors

- **Version conflicts**: Ensure version in Chart.yaml is incremented
- **Missing files**: Check all referenced files exist
- **Permission errors**: Ensure scripts are executable (`chmod +x`)

### Repository Issues

- **404 errors**: Wait a few minutes for GitHub Pages to update
- **Old versions**: Run `helm repo update` to refresh
- **Index issues**: Ensure index.yaml is properly formatted

## CI/CD Pipeline

### Pull Request Checks

The following checks run on every PR:
1. Chart linting (helm lint)
2. Version validation
3. Template validation
4. Installation test (using KIND cluster)

### Release Process

On merge to main:
1. Charts are automatically packaged
2. Published to gh-pages branch
3. Available immediately via Helm repository

## Questions?

- Check existing charts for examples
- Review GitHub Actions logs for CI/CD issues
- Open an issue for bugs or feature requests
- Contact the team at support@514labs.com 