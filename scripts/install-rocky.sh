#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/scripts/common.sh"

print_info "Installing dependencies for Rocky Linux..."

# Enable EPEL repository
print_info "Enabling EPEL repository..."
sudo dnf install -y epel-release
sudo dnf config-manager --set-enabled crb

# Update package list
print_info "Updating package list..."
sudo dnf update -y

# Install development tools
print_info "Installing development tools..."
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y curl wget git unzip

# Install Neovim from GitHub releases (Rocky repos may have older versions)
if ! check_neovim_version; then
    print_info "Installing Neovim from GitHub releases..."
    NVIM_VERSION="v0.10.2"
    wget -q https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz
    sudo tar -xzf nvim-linux64.tar.gz -C /opt/
    sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
    rm nvim-linux64.tar.gz
    print_success "Neovim installed"
fi

# Install Node.js (for LSP servers)
if ! check_command node; then
    print_info "Installing Node.js..."
    curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
    sudo dnf install -y nodejs
    print_success "Node.js installed"
fi

# Install Python and pip
if ! check_command python3; then
    print_info "Installing Python3..."
    sudo dnf install -y python3 python3-pip
    print_success "Python3 installed"
fi

# Install ripgrep (for Telescope grep)
if ! check_command rg; then
    print_info "Installing ripgrep..."
    sudo dnf install -y ripgrep
    print_success "ripgrep installed"
fi

# Install fd-find (for Telescope file finding)
if ! check_command fd; then
    print_info "Installing fd-find..."
    sudo dnf install -y fd-find
    print_success "fd-find installed"
fi

# Install LazyGit (optional but useful)
if ! check_command lazygit; then
    print_info "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz
    print_success "lazygit installed"
fi

# Install a Nerd Font
print_info "Installing Nerd Font..."
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
if [[ ! -f "JetBrainsMonoNerdFont-Regular.ttf" ]]; then
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
    unzip -q JetBrainsMono.zip
    rm JetBrainsMono.zip
    # Install fontconfig if not present
    if ! command -v fc-cache &> /dev/null; then
        sudo dnf install -y fontconfig
    fi
    fc-cache -fv
    print_success "JetBrains Mono Nerd Font installed"
else
    print_success "Nerd Font already installed"
fi

# Setup Neovim configuration
cd "$SCRIPT_DIR"
setup_config

print_success "Rocky Linux installation completed!"
