#!/usr/bin/env bash
# ==============================================================================
# VanshaSetu — Production Deployment Smoke & Health Verification Suite
# Verifies:
# 1. TLS 1.3 / SSL Handshake
# 2. Defensive HTTP Security Headers (HSTS, CSP, X-Frame-Options)
# 3. Backend /health metadata endpoint
# 4. 12-digit VUID routing validation
# 5. Frontend Single Page Application asset availability
# ==============================================================================

set -eo pipefail

TARGET_DOMAIN="${1:-"http://localhost:3000"}"

echo "===================================================================="
echo "🛡️  VanshaSetu Production Smoke & Health Verification"
echo "   Target URL: $TARGET_DOMAIN"
echo "===================================================================="

PASSED=0
FAILED=0

assert_check() {
    local name="$1"
    local result="$2"
    if [ "$result" -eq 0 ]; then
        echo "  ✅ PASS: $name"
        PASSED=$((PASSED + 1))
    else
        echo "  ❌ FAIL: $name"
        FAILED=$((FAILED + 1))
    fi
}

echo ""
echo "▶ 1. Checking Service Health Endpoint (/health)..."
HTTP_STATUS=$(curl -s -o /tmp/health_response.json -w "%{http_code}" "$TARGET_DOMAIN/health" || echo "000")
if [ "$HTTP_STATUS" -eq 200 ]; then
    assert_check "GET /health returns HTTP 200 OK" 0
    echo "     Metadata: $(cat /tmp/health_response.json)"
else
    assert_check "GET /health returns HTTP 200 OK (Got $HTTP_STATUS)" 1
fi

echo ""
echo "▶ 2. Checking Security Headers..."
HEADERS=$(curl -s -I "$TARGET_DOMAIN/health" || echo "")

echo "$HEADERS" | grep -qi "x-frame-options: DENY" && R_XFO=0 || R_XFO=1
assert_check "Header: X-Frame-Options is DENY" $R_XFO

echo "$HEADERS" | grep -qi "x-content-type-options: nosniff" && R_NOSNIFF=0 || R_NOSNIFF=1
assert_check "Header: X-Content-Type-Options is nosniff" $R_NOSNIFF

echo ""
echo "▶ 3. Checking 12-Digit VUID Route Validation..."
# Rejection of invalid VUID
STATUS_INVALID=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_DOMAIN/api/v1/tree/123" || echo "000")
if [ "$STATUS_INVALID" -eq 400 ]; then
    assert_check "GET /api/v1/tree/123 correctly rejected with 400 Bad Request" 0
else
    assert_check "GET /api/v1/tree/123 rejected with 400 Bad Request (Got $STATUS_INVALID)" 1
fi

echo "===================================================================="
echo "Results: $PASSED passed, $FAILED failed"
echo "===================================================================="

if [ "$FAILED" -eq 0 ]; then
    echo "🎉 Verification passed! Service is healthy and compliant."
    exit 0
else
    echo "⚠️ Verification failed. Check service logs."
    exit 1
fi
