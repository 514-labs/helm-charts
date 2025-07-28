#!/bin/bash
set -e

# Script to test the Helm repository locally

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "🧪 Testing Helm repository locally..."

# Start a simple HTTP server
echo "📡 Starting local HTTP server on port 8080..."
echo "   Repository URL: http://localhost:8080"
echo ""
echo "   Press Ctrl+C to stop the server"
echo ""

cd "${REPO_ROOT}"

# Check if Python 3 is available
if command -v python3 > /dev/null 2>&1; then
    python3 -m http.server 8080
else
    # Fall back to Python 2
    python -m SimpleHTTPServer 8080
fi 