#!/usr/bin/env bash
# Agent Scaffold Uninstaller
# Remove installed scaffolds from Hermes Agent and/or OpenClaw

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Agent Scaffold Uninstaller                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# List of scaffolds to remove
SCAFFOLDS=(
    "task-execution-reporter"
    "pure-output"
    "self-verification"
)

# Remove from Hermes
if [[ -d "$HOME/.hermes/skills" ]]; then
    echo -e "${BLUE}Removing from Hermes...${NC}"
    for scaffold in "${SCAFFOLDS[@]}"; do
        if [[ -d "$HOME/.hermes/skills/$scaffold" ]]; then
            rm -rf "$HOME/.hermes/skills/$scaffold"
            echo -e "  ${GREEN}✓${NC} Removed $scaffold"
        fi
    done
    echo ""
fi

# Remove from OpenClaw
if [[ -d "$HOME/.openclaw/skills" ]]; then
    echo -e "${BLUE}Removing from OpenClaw...${NC}"
    for scaffold in "${SCAFFOLDS[@]}"; do
        if [[ -d "$HOME/.openclaw/skills/$scaffold" ]]; then
            rm -rf "$HOME/.openclaw/skills/$scaffold"
            echo -e "  ${GREEN}✓${NC} Removed $scaffold"
        fi
    done
    echo ""
fi

echo -e "${GREEN}✓ Uninstall complete${NC}"
echo ""
echo "Note: The agent-scaffold repository is still at $(pwd)"
echo "To remove it: rm -rf $(pwd)"
echo ""
