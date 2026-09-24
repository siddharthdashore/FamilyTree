#!/usr/bin/env bash
# ==============================================================================
# VanshaSetu — BigRock cPanel Deployment Automation Script
# Supports:
# 1. Direct SSH / SCP automated upload & extraction
# 2. Local archive packaging for cPanel File Manager upload
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"

echo "===================================================================="
echo "📦 VanshaSetu BigRock cPanel Deployment Utility"
echo "===================================================================="

# Check if build exists, if not trigger build
if [ ! -f "$DIST_DIR/public_html.tar.gz" ] || [ ! -f "$DIST_DIR/vanshasetu-api.tar.gz" ]; then
    echo "⚠️ Distribution archives not found in $DIST_DIR. Running build_production.sh first..."
    "$SCRIPT_DIR/build_production.sh"
fi

# Load deployment environment if present
DEPLOY_ENV="$ROOT_DIR/.deploy.env"
if [ -f "$DEPLOY_ENV" ]; then
    echo "Loading deployment parameters from .deploy.env..."
    # shellcheck disable=SC1090
    source "$DEPLOY_ENV"
fi

CPANEL_USER="${CPANEL_USER:-""}"
CPANEL_HOST="${CPANEL_HOST:-""}"
CPANEL_PORT="${CPANEL_PORT:-"22"}"
REMOTE_PATH="${REMOTE_PATH:-"~"}"

if [ -n "$CPANEL_USER" ] && [ -n "$CPANEL_HOST" ]; then
    echo "▶ Deploying automatically to $CPANEL_USER@$CPANEL_HOST:$CPANEL_PORT via SSH/SCP..."
    
    echo "1. Uploading archives..."
    scp -P "$CPANEL_PORT" "$DIST_DIR/public_html.tar.gz" "$DIST_DIR/vanshasetu-api.tar.gz" "$CPANEL_USER@$CPANEL_HOST:$REMOTE_PATH/"
    
    echo "2. Extracting archives remotely..."
    ssh -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" bash << EOF
set -e
echo "Extracting public_html..."
tar -xzf $REMOTE_PATH/public_html.tar.gz -C $REMOTE_PATH/public_html/
rm $REMOTE_PATH/public_html.tar.gz

echo "Extracting vanshasetu-api..."
mkdir -p $REMOTE_PATH/vanshasetu-api
tar -xzf $REMOTE_PATH/vanshasetu-api.tar.gz -C $REMOTE_PATH/vanshasetu-api/
rm $REMOTE_PATH/vanshasetu-api.tar.gz

cd $REMOTE_PATH/vanshasetu-api
if command -v npm >/dev/null 2>&1; then
    echo "Installing production node dependencies..."
    npm install --production
fi

echo "Triggering Phusion Passenger application reload..."
mkdir -p tmp
touch tmp/restart.txt

echo "Remote deployment successfully completed!"
EOF

    echo "✅ Remote deployment to BigRock cPanel finished successfully!"
else
    echo "ℹ️ Remote credentials not set (CPANEL_USER / CPANEL_HOST)."
    echo "📦 Deployment bundles are ready for manual upload via cPanel File Manager:"
    echo "   1. Upload '$DIST_DIR/public_html.tar.gz' to cPanel 'public_html/' and click 'Extract'."
    echo "   2. Upload '$DIST_DIR/vanshasetu-api.tar.gz' to cPanel 'vanshasetu-api/' and click 'Extract'."
    echo "   3. In cPanel 'Setup Node.js App': click 'Run NPM Install' and 'Restart Application'."
fi

echo "===================================================================="
