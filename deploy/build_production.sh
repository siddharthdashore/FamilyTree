#!/usr/bin/env bash
# ==============================================================================
# VanshaSetu — Production Build Pipeline
# Automated Multiplatform Asset Compilation & CloudLinux Staging Script
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"

echo "===================================================================="
echo "🚀 Starting VanshaSetu Production Build Pipeline"
echo "   Root Directory: $ROOT_DIR"
echo "   Output Directory: $DIST_DIR"
echo "===================================================================="

# Step 1: Pre-Build Quality Gate (100% Test Pass Mandate)
echo ""
echo "▶ Step 1/5: Executing Sovereign Constitutional Quality Gate..."
cd "$ROOT_DIR"
npm run test:all
echo "✅ All automated test suites passed successfully!"

# Step 2: Clean and Initialize Output Directories
echo ""
echo "▶ Step 2/5: Preparing distribution staging directories..."
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR/public_html"
mkdir -p "$DIST_DIR/vanshasetu-api"

# Step 3: Compile Flutter Web Release Bundle
echo ""
echo "▶ Step 3/5: Compiling Flutter Web production release bundle..."
cd "$ROOT_DIR/client"
flutter build web --release --no-wasm-dry-run

echo "Copying compiled Web assets to dist/public_html..."
cp -R "$ROOT_DIR/client/build/web/"* "$DIST_DIR/public_html/"
cp "$SCRIPT_DIR/.htaccess" "$DIST_DIR/public_html/.htaccess"
echo "✅ Flutter Web assets staged in dist/public_html."

# Step 4: Prepare Node.js Backend API for CloudLinux Passenger
echo ""
echo "▶ Step 4/5: Staging Node.js Backend API for CloudLinux Passenger..."
mkdir -p "$DIST_DIR/vanshasetu-api/src"
mkdir -p "$DIST_DIR/vanshasetu-api/tmp" # Needed for Passenger touch restart.txt

cp -R "$ROOT_DIR/backend/src/"* "$DIST_DIR/vanshasetu-api/src/"
cp "$ROOT_DIR/backend/server.js" "$DIST_DIR/vanshasetu-api/server.js"
cp "$ROOT_DIR/backend/package.json" "$DIST_DIR/vanshasetu-api/package.json"
cp "$ROOT_DIR/backend/package-lock.json" "$DIST_DIR/vanshasetu-api/package-lock.json"
cp "$ROOT_DIR/backend/.env.example" "$DIST_DIR/vanshasetu-api/.env.example"

# Create Passenger application entrypoint wrapper (app.js)
cat << 'EOF' > "$DIST_DIR/vanshasetu-api/app.js"
// Phusion Passenger / CloudLinux Application Wrapper
// Delegates execution directly to server.js
require('./server.js');
EOF

echo "✅ Node.js API staged in dist/vanshasetu-api."

# Step 5: Generate Release Checksums & Packaging
echo ""
echo "▶ Step 5/5: Generating deployment archives and cryptographic checksums..."
cd "$DIST_DIR"
tar -czf "$DIST_DIR/public_html.tar.gz" -C "$DIST_DIR/public_html" .
tar -czf "$DIST_DIR/vanshasetu-api.tar.gz" -C "$DIST_DIR/vanshasetu-api" .

# Compute SHA-256 checksums
if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 public_html.tar.gz vanshasetu-api.tar.gz > "$DIST_DIR/checksums.sha256"
elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum public_html.tar.gz vanshasetu-api.tar.gz > "$DIST_DIR/checksums.sha256"
fi

echo "===================================================================="
echo "🎉 Production Build Completed Successfully!"
echo "   Artifacts generated in $DIST_DIR:"
echo "   - public_html/          (Flutter Web SPA + .htaccess)"
echo "   - vanshasetu-api/       (Node.js CloudLinux Passenger Service)"
echo "   - public_html.tar.gz    (Compressed Frontend Archive)"
echo "   - vanshasetu-api.tar.gz (Compressed Backend Archive)"
echo "   - checksums.sha256      (Cryptographic SHA-256 Signatures)"
echo "===================================================================="
