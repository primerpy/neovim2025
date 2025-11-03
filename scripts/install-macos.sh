#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/scripts/common.sh"

print_info "Installing dependencies for macOS..."

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    print_success "Homebrew installed"
else
    print_success "Homebrew already installed"
fi

# Update Homebrew
print_info "Updating Homebrew..."
brew update

# Install Neovim
if ! check_neovim_version; then
    print_info "Installing Neovim..."
    brew install neovim
    print_success "Neovim installed"
fi

# Install Node.js
if ! check_command node; then
    print_info "Installing Node.js..."
    brew install node
    print_success "Node.js installed"
fi

# Install Python
if ! check_command python3; then
    print_info "Installing Python3..."
    brew install python
    print_success "Python3 installed"
fi

# Install ripgrep
if ! check_command rg; then
    print_info "Installing ripgrep..."
    brew install ripgrep
    print_success "ripgrep installed"
fi

# Install fd
if ! check_command fd; then
    print_info "Installing fd..."
    brew install fd
    print_success "fd installed"
fi

# Install LazyGit
if ! check_command lazygit; then
    print_info "Installing lazygit..."
    brew install lazygit
    print_success "lazygit installed"
fi

# Install a Nerd Font
print_info "Installing Nerd Font..."
brew tap homebrew/cask-fonts
if ! brew list --cask font-jetbrains-mono-nerd-font &> /dev/null; then
    brew install --cask font-jetbrains-mono-nerd-font
    print_success "JetBrains Mono Nerd Font installed"
else
    print_success "Nerd Font already installed"
fi

# Setup Neovim configuration
cd "$SCRIPT_DIR"
setup_config

print_success "macOS installation completed!"
print_info "You may need to configure your terminal to use the JetBrains Mono Nerd Font"
