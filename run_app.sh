#!/usr/bin/env bash

# ==============================================================================
# VanshaSetu (वन्शसेतु) — Application Runner Script
# Usage:
#   ./run_app.sh web       # Launches Flutter Web on Chrome
#   ./run_app.sh ios       # Launches on connected iOS device or iOS Simulator
#   ./run_app.sh android   # Launches on connected Android device or Emulator
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$SCRIPT_DIR/client"
BACKEND_DIR="$SCRIPT_DIR/backend"

# Color Codes for Terminal Output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function print_usage() {
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${CYAN}  VanshaSetu (वन्शसेतु) — Digital Public Infrastructure App Runner  ${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo -e "\n${YELLOW}Usage:${NC}"
    echo -e "  ./run_app.sh <platform> [options]"
    echo -e "\n${YELLOW}Supported Platforms:${NC}"
    echo -e "  ${GREEN}web${NC}      : Run Flutter Web on Google Chrome"
    echo -e "  ${GREEN}ios${NC}      : Run on connected iOS device or iOS Simulator"
    echo -e "  ${GREEN}android${NC}  : Run on connected Android device or Emulator"
    echo -e "  ${GREEN}macos${NC}    : Run as native macOS desktop app"
    echo -e "\n${YELLOW}Examples:${NC}"
    echo -e "  ./run_app.sh web"
    echo -e "  ./run_app.sh ios"
    echo -e "  ./run_app.sh android"
    echo -e "  ./run_app.sh web --release"
    echo -e "\n${CYAN}================================================================${NC}"
}

# Ensure at least one argument is provided
if [ $# -lt 1 ]; then
    print_usage
    exit 1
fi

PLATFORM=$(echo "$1" | tr '[:upper:]' '[:lower:]')

# Handle help command immediately without launching services
if [ "$PLATFORM" = "help" ] || [ "$PLATFORM" = "--help" ] || [ "$PLATFORM" = "-h" ]; then
    print_usage
    exit 0
fi

shift # Shift argument so remaining flags pass to flutter run

# Check if backend Node.js server is already running on port 3000
BACKEND_PID=""
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "${GREEN}✓ VanshaSetu Middleware is already running on port 3000${NC}"
else
    echo -e "${YELLOW}⚡ Starting VanshaSetu Middleware API on port 3000 (background)...${NC}"
    (cd "$BACKEND_DIR" && npm start > "$SCRIPT_DIR/backend.log" 2>&1) &
    BACKEND_PID=$!
    sleep 2
    if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
        echo -e "${GREEN}✓ VanshaSetu Middleware API started successfully (PID: $BACKEND_PID)${NC}"
    else
        echo -e "${YELLOW}! Middleware could not bind port 3000 (check backend.log). Continuing with app launch...${NC}"
    fi
fi

# Cleanup function on script exit
cleanup() {
    if [ -n "$BACKEND_PID" ]; then
        echo -e "\n${YELLOW}Shutting down background middleware (PID: $BACKEND_PID)...${NC}"
        kill "$BACKEND_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT INT TERM

cd "$CLIENT_DIR"

case "$PLATFORM" in
    web)
        echo -e "${CYAN}🚀 Launching VanshaSetu on Web (Chrome)...${NC}"
        flutter run -d chrome "$@"
        ;;
    ios)
        echo -e "${CYAN}🚀 Launching VanshaSetu on iOS...${NC}"
        flutter run -d ios "$@"
        ;;
    android)
        echo -e "${CYAN}🚀 Launching VanshaSetu on Android...${NC}"
        flutter run -d android "$@"
        ;;
    macos)
        echo -e "${CYAN}🚀 Launching VanshaSetu on macOS Desktop...${NC}"
        flutter run -d macos "$@"
        ;;
    help|--help|-h)
        print_usage
        exit 0
        ;;
    *)
        echo -e "${RED}Error: Unknown platform '$PLATFORM'.${NC}"
        print_usage
        exit 1
        ;;
esac
