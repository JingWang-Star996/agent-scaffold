#!/usr/bin/env bash
# Agent Scaffold Installer
# Install optional training aids for LLM agents (Hermes, OpenClaw)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCAFFOLDS_DIR="$SCRIPT_DIR/scaffolds"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
INSTALL_HERMES=false
INSTALL_OPENCLAW=false
ONLY_SCAFFOLDS=""

if [[ "$#" -eq 0 ]]; then
    INSTALL_HERMES=true
    INSTALL_OPENCLAW=true
else
    for arg in "$@"; do
        case $arg in
            --hermes)
                INSTALL_HERMES=true
                ;;
            --openclaw)
                INSTALL_OPENCLAW=true
                ;;
            --only=*)
                ONLY_SCAFFOLDS="${arg#*=}"
                ;;
            --help|-h)
                echo "Usage: $0 [options]"
                echo ""
                echo "Options:"
                echo "  --hermes          Install to Hermes Agent only"
                echo "  --openclaw        Install to OpenClaw only"
                echo "  --only=<list>     Install specific scaffolds (comma-separated)"
                echo "  --help, -h        Show this help"
                echo ""
                echo "Available scaffolds:"
                ls -1 "$SCAFFOLDS_DIR" | grep -v '\.md$' | sed 's/^/  - /'
                echo ""
                echo "Examples:"
                echo "  $0                           # Install all to both"
                echo "  $0 --hermes                  # Install all to Hermes"
                echo "  $0 --only=pure-output        # Install only pure-output"
                echo "  $0 --only=task-execution-reporter,pure-output"
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $arg${NC}"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
fi

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Agent Scaffold Installer                  ║${NC}"
echo -e "${BLUE}║     Training wheels for LLM agents            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Determine which scaffolds to install
if [[ -n "$ONLY_SCAFFOLDS" ]]; then
    IFS=',' read -ra SCAFFOLD_LIST <<< "$ONLY_SCAFFOLDS"
    echo -e "${BLUE}Installing specific scaffolds: ${SCAFFOLD_LIST[*]}${NC}"
else
    SCAFFOLD_LIST=()
    for scaffold_dir in "$SCAFFOLDS_DIR"/*/; do
        if [[ -d "$scaffold_dir" ]]; then
            scaffold_name=$(basename "$scaffold_dir")
            SCAFFOLD_LIST+=("$scaffold_name")
        fi
    done
    echo -e "${BLUE}Installing all scaffolds (${#SCAFFOLD_LIST[@]} total)${NC}"
fi

echo ""

# Detect installations
HERMES_DIR=""
OPENCLAW_DIR=""

if $INSTALL_HERMES; then
    if [[ -d "$HOME/.hermes" ]]; then
        HERMES_DIR="$HOME/.hermes/skills"
        echo -e "${GREEN}✓ Detected Hermes at $HOME/.hermes${NC}"
    else
        echo -e "${YELLOW}⚠ Hermes not found at $HOME/.hermes${NC}"
    fi
fi

if $INSTALL_OPENCLAW; then
    if [[ -d "$HOME/.openclaw" ]]; then
        OPENCLAW_DIR="$HOME/.openclaw/skills"
        echo -e "${GREEN}✓ Detected OpenClaw at $HOME/.openclaw${NC}"
    else
        echo -e "${YELLOW}⚠ OpenClaw not found at $HOME/.openclaw${NC}"
    fi
fi

# Check if anything to install
if [[ -z "$HERMES_DIR" && -z "$OPENCLAW_DIR" ]]; then
    echo ""
    echo -e "${RED}✗ No compatible agent installations found${NC}"
    echo ""
    echo "Please install Hermes or OpenClaw first:"
    echo "  Hermes:  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash"
    echo "  OpenClaw: https://github.com/anthropics/openclaw"
    exit 1
fi

echo ""

# Install function
install_to() {
    local target_dir="$1"
    local target_name="$2"
    
    echo -e "${BLUE}Installing to $target_name...${NC}"
    
    mkdir -p "$target_dir"
    
    local count=0
    for scaffold_name in "${SCAFFOLD_LIST[@]}"; do
        scaffold_source="$SCAFFOLDS_DIR/$scaffold_name"
        
        if [[ ! -d "$scaffold_source" ]]; then
            echo -e "  ${YELLOW}⚠ Scaffold not found: $scaffold_name${NC}"
            continue
        fi
        
        dest="$target_dir/$scaffold_name"
        
        # Remove existing if present
        if [[ -d "$dest" ]]; then
            rm -rf "$dest"
        fi
        
        # Copy
        cp -r "$scaffold_source" "$dest"
        ((count++))
        echo -e "  ${GREEN}✓${NC} $scaffold_name"
    done
    
    echo ""
    echo -e "${GREEN}✓ Installed $count scaffolds to $target_name${NC}"
    echo ""
}

# Install to detected locations
if [[ -n "$HERMES_DIR" ]]; then
    install_to "$HERMES_DIR" "Hermes"
fi

if [[ -n "$OPENCLAW_DIR" ]]; then
    install_to "$OPENCLAW_DIR" "OpenClaw"
fi

echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""
echo "Next steps:"
echo ""

if [[ -n "$HERMES_DIR" ]]; then
    echo -e "${BLUE}Hermes:${NC}"
    echo "  1. Start a new session: hermes"
    echo "  2. Load a scaffold: /skill task-execution-reporter"
    echo "  3. Scaffolds activate based on trigger conditions"
    echo ""
fi

if [[ -n "$OPENCLAW_DIR" ]]; then
    echo -e "${BLUE}OpenClaw:${NC}"
    echo "  1. Start a new session"
    echo "  2. Load a scaffold: Load skill: task-execution-reporter"
    echo ""
fi

echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo ""
echo "Remember: Scaffolds are optional training aids."
echo "Disable them when you no longer need them."
echo ""
echo "For more information, see:"
echo "  - README.md (English)"
echo "  - README.zh-CN.md (中文)"
echo ""
