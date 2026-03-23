#!/usr/bin/env bash

# Common functions used by all installation scripts

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        print_success "$1 is already installed"
        return 0
    else
        print_info "$1 is not installed, will install..."
        return 1
    fi
}

backup_existing_config() {
    local nvim_config="$HOME/.config/nvim"

    if [[ -d "$nvim_config" ]] && [[ "$nvim_config" != "$SCRIPT_DIR" ]]; then
        local backup_dir="${nvim_config}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Existing Neovim config found"
        print_info "Creating backup at: $backup_dir"
        mv "$nvim_config" "$backup_dir"
    fi
}

setup_config() {
    local nvim_config="$HOME/.config/nvim"

    # If script is already in the correct location, do nothing
    if [[ "$SCRIPT_DIR" == "$nvim_config" ]]; then
        print_success "Configuration is already in place"
        return 0
    fi

    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"

    # Backup existing config if present
    backup_existing_config

    # Create symlink or copy configuration
    if [[ -w "$HOME/.config" ]]; then
        print_info "Creating symlink to configuration..."
        ln -sf "$SCRIPT_DIR" "$nvim_config"
        print_success "Configuration symlinked successfully"
    else
        print_info "Copying configuration..."
        cp -r "$SCRIPT_DIR" "$nvim_config"
        print_success "Configuration copied successfully"
    fi
}

check_neovim_version() {
    if command -v nvim &> /dev/null; then
        # Extract version number (works on both macOS and Linux)
        local version=$(nvim --version | head -n1 | sed -E 's/.*v([0-9]+\.[0-9]+).*/\1/')
        local major=$(echo "$version" | cut -d. -f1)
        local minor=$(echo "$version" | cut -d. -f2)

        # Check if version numbers are valid integers
        if [[ "$major" =~ ^[0-9]+$ ]] && [[ "$minor" =~ ^[0-9]+$ ]]; then
            if [[ $major -gt 0 ]] || [[ $major -eq 0 && $minor -ge 11 ]]; then
                print_success "Neovim version $version is compatible"
                return 0
            else
                print_warning "Neovim version $version found, but 0.11+ is required"
                return 1
            fi
        fi
    fi
    return 1
}

install_neovim_github() {
    # Fetch the latest stable release version from GitHub API
    local latest_version
    latest_version=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep -Po '"tag_name": "\K[^"]*')
    if [[ -z "$latest_version" ]]; then
        print_error "Failed to fetch latest Neovim version from GitHub"
        return 1
    fi
    print_info "Latest stable Neovim version: $latest_version"

    # Detect architecture
    local arch
    arch=$(uname -m)
    local tarball
    if [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
        tarball="nvim-linux-arm64.tar.gz"
    else
        tarball="nvim-linux-x86_64.tar.gz"
    fi

    wget -q "https://github.com/neovim/neovim/releases/download/${latest_version}/${tarball}"
    sudo rm -rf /opt/nvim-linux64
    sudo tar -xzf "$tarball" -C /opt/
    # Normalize directory name regardless of archive contents
    local extracted_dir
    extracted_dir=$(tar -tzf "$tarball" | head -1 | cut -d/ -f1)
    if [[ "$extracted_dir" != "nvim-linux64" ]]; then
        sudo mv "/opt/${extracted_dir}" /opt/nvim-linux64
    fi
    sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
    rm "$tarball"
    print_success "Neovim $latest_version installed"
}
