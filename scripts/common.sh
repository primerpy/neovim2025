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
    local required_minor=${1:-11}  # Default to 0.11+ if not specified
    if command -v nvim &> /dev/null; then
        # Extract version number (works on both macOS and Linux)
        local version=$(nvim --version | head -n1 | sed -E 's/.*v([0-9]+\.[0-9]+).*/\1/')
        local major=$(echo "$version" | cut -d. -f1)
        local minor=$(echo "$version" | cut -d. -f2)

        # Check if version numbers are valid integers
        if [[ "$major" =~ ^[0-9]+$ ]] && [[ "$minor" =~ ^[0-9]+$ ]]; then
            if [[ $major -gt 0 ]] || [[ $major -eq 0 && $minor -ge $required_minor ]]; then
                print_success "Neovim version $version is compatible (requires 0.${required_minor}+)"
                return 0
            else
                print_warning "Neovim version $version found, but 0.${required_minor}+ is required"
                return 1
            fi
        fi
    fi
    return 1
}

remove_old_neovim() {
    print_info "Checking for old Neovim installations to clean up..."

    # Remove from /opt if exists
    if [[ -d "/opt/nvim-linux64" ]]; then
        print_info "Removing old Neovim from /opt/nvim-linux64..."
        sudo rm -rf /opt/nvim-linux64
    fi

    # Remove symlink from /usr/local/bin
    if [[ -L "/usr/local/bin/nvim" ]]; then
        print_info "Removing old Neovim symlink from /usr/local/bin..."
        sudo rm -f /usr/local/bin/nvim
    fi

    # Remove from /usr/local if installed there directly
    if [[ -f "/usr/local/bin/nvim" ]] && [[ ! -L "/usr/local/bin/nvim" ]]; then
        print_info "Removing old Neovim binary from /usr/local/bin..."
        sudo rm -f /usr/local/bin/nvim
    fi

    # Remove package manager installed versions
    if command -v dnf &> /dev/null; then
        if dnf list installed neovim &> /dev/null 2>&1; then
            print_info "Removing dnf-installed Neovim..."
            sudo dnf remove -y neovim 2>/dev/null || true
        fi
    elif command -v apt &> /dev/null; then
        if dpkg -l neovim &> /dev/null 2>&1; then
            print_info "Removing apt-installed Neovim..."
            sudo apt remove -y neovim 2>/dev/null || true
        fi
    fi

    print_success "Old Neovim installations cleaned up"
}
