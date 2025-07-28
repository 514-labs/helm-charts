#!/bin/bash
set -e

# Script to package Helm charts and update repository index

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CHARTS_DIR="${REPO_ROOT}/charts"
PACKAGES_DIR="${REPO_ROOT}/packages"
REPO_URL="https://514-labs.github.io/helm-charts/"

echo "🚀 Starting Helm chart packaging process..."

# Create packages directory if it doesn't exist
mkdir -p "${PACKAGES_DIR}"

# Find all charts
CHARTS=$(find "${CHARTS_DIR}" -mindepth 1 -maxdepth 1 -type d)

if [ -z "$CHARTS" ]; then
    echo "❌ No charts found in ${CHARTS_DIR}"
    exit 1
fi

echo "📦 Found charts to package:"
for chart in $CHARTS; do
    echo "  - $(basename "$chart")"
done

# Package each chart
for chart in $CHARTS; do
    chart_name=$(basename "$chart")
    echo ""
    echo "📋 Processing chart: ${chart_name}"
    
    # Lint the chart first
    echo "  🔍 Linting chart..."
    if helm lint "$chart"; then
        echo "  ✅ Lint passed"
    else
        echo "  ❌ Lint failed for ${chart_name}, skipping..."
        continue
    fi
    
    # Package the chart
    echo "  📦 Packaging chart..."
    if helm package "$chart" -d "${PACKAGES_DIR}"; then
        echo "  ✅ Successfully packaged ${chart_name}"
    else
        echo "  ❌ Failed to package ${chart_name}"
        exit 1
    fi
done

# Update repository index
echo ""
echo "📑 Updating repository index..."
cd "${REPO_ROOT}"

# Try to fetch existing index.yaml from gh-pages branch
echo "  📥 Fetching existing index.yaml from gh-pages..."
if git show origin/gh-pages:index.yaml > index.yaml.tmp 2>/dev/null; then
    mv index.yaml.tmp index.yaml
    echo "  ✅ Found existing index.yaml from gh-pages"
else
    echo "  ℹ️  No existing index.yaml found in gh-pages"
    rm -f index.yaml.tmp
fi

# If index.yaml exists, merge with it; otherwise create new
if [ -f "index.yaml" ]; then
    echo "  📄 Merging with existing index.yaml..."
    helm repo index . --url "${REPO_URL}" --merge index.yaml
else
    echo "  📄 Creating new index.yaml..."
    helm repo index . --url "${REPO_URL}"
fi

echo "✅ Repository index updated successfully"

# Clean up old packages (optional - keeps only latest 3 versions of each chart)
echo ""
echo "🧹 Cleaning up old packages..."
cd "${PACKAGES_DIR}"
for chart_pattern in $(ls *.tgz 2>/dev/null | sed 's/-[0-9].*//' | sort -u); do
    # Keep only the 3 most recent versions
    ls -t ${chart_pattern}-*.tgz 2>/dev/null | tail -n +4 | xargs -r rm -v
done

echo ""
echo "✅ Chart packaging complete!"
echo ""
echo "📌 Next steps:"
echo "  1. Review the changes"
echo "  2. Commit the updated index.yaml"
echo "  3. Push to the gh-pages branch to publish" 