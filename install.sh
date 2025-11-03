#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "${SCRIPT_DIR}/scripts/common.sh"

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Neovim Configuration Installer${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu)
                OS="ubuntu"
                ;;
            debian)
                OS="debian"
                ;;
            rocky|rhel)
                OS="rocky"
                ;;
            *)
                print_error "Unsupported Linux distribution: $ID"
                exit 1
                ;;
        esac
    else
        print_error "Unable to detect operating system"
        exit 1
    fi

    print_info "Detected OS: $OS"
}

main() {
    print_header

    # Detect operating system
    detect_os

    # Run OS-specific installation
    print_info "Running ${OS} installation script..."
    bash "${SCRIPT_DIR}/scripts/install-${OS}.sh"

    if [[ $? -eq 0 ]]; then
        echo ""
        print_success "Installation completed successfully!"
        echo ""
        print_info "Next steps:"
        echo "  1. Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
        echo "  2. Start Neovim: nvim"
        echo "  3. Lazy.nvim will automatically install plugins"
        echo "  4. Mason will automatically install LSP servers and tools"
        echo "  5. Run :checkhealth to verify everything is working"
        echo ""
        print_warning "Note: First launch may take a few minutes to install everything"
    else
        print_error "Installation failed"
        exit 1
    fi
}

main "$@"
