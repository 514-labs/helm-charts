#!/bin/bash
set -e

# Script to publish packaged charts to gh-pages branch

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PACKAGES_DIR="${REPO_ROOT}/packages"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TEMP_DIR=$(mktemp -d)

echo "🚀 Starting chart publishing process..."

# Check if index.yaml exists
if [ ! -f "${REPO_ROOT}/index.yaml" ]; then
    echo "❌ index.yaml not found. Run package-charts.sh first!"
    exit 1
fi

# Check if there are any packaged charts
if [ ! -d "${PACKAGES_DIR}" ] || [ -z "$(ls -A ${PACKAGES_DIR}/*.tgz 2>/dev/null)" ]; then
    echo "❌ No packaged charts found. Run package-charts.sh first!"
    exit 1
fi

# Copy files to temp directory before switching branches
echo "📋 Copying files to temporary directory..."
cp "${REPO_ROOT}/index.yaml" "${TEMP_DIR}/"
mkdir -p "${TEMP_DIR}/packages"
cp "${PACKAGES_DIR}"/*.tgz "${TEMP_DIR}/packages/" 2>/dev/null || true

# Store current changes
echo "💾 Stashing current changes..."
git stash push -m "Publishing charts from ${CURRENT_BRANCH}" || echo "No changes to stash"

# Checkout gh-pages branch
echo "🔄 Switching to gh-pages branch..."
git checkout gh-pages
git pull origin gh-pages

# Copy packaged charts and index from temp directory
echo "📦 Copying charts and index..."
cp "${TEMP_DIR}/index.yaml" .
mkdir -p packages
cp "${TEMP_DIR}/packages"/*.tgz packages/ 2>/dev/null || true

# Clean up temp directory
rm -rf "${TEMP_DIR}"

# Add and commit changes
echo "📝 Committing changes..."
git add index.yaml packages/
git commit -m "Update charts from ${CURRENT_BRANCH} - $(date '+%Y-%m-%d %H:%M:%S')" || {
    echo "⚠️  No changes to commit"
}

# Push to gh-pages
echo "📤 Pushing to gh-pages..."
git push origin gh-pages

# Switch back to original branch
echo "🔄 Switching back to ${CURRENT_BRANCH}..."
git checkout "${CURRENT_BRANCH}"

# Restore stashed changes
echo "♻️  Restoring stashed changes..."
git stash pop || echo "No stashed changes to restore"

echo ""
echo "✅ Charts published successfully!"
echo "🌐 Your charts will be available at: https://514-labs.github.io/helm-charts/"
echo ""
echo "📌 To use the repository:"
echo "  helm repo add 514labs https://514-labs.github.io/helm-charts/"
echo "  helm repo update"
echo "  helm search repo 514labs" 