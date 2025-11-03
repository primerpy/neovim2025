#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/scripts/common.sh"

print_info "Installing dependencies for Ubuntu..."

# Update package list
print_info "Updating package list..."
sudo apt-get update

# Install build essentials
print_info "Installing build essentials..."
sudo apt-get install -y build-essential curl wget git unzip

# Install Neovim
if ! check_neovim_version; then
    print_info "Installing Neovim..."
    # Install from PPA for latest version
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update
    sudo apt-get install -y neovim
    print_success "Neovim installed"
fi

# Install Node.js (for LSP servers)
if ! check_command node; then
    print_info "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_success "Node.js installed"
fi

# Install Python and pip
if ! check_command python3; then
    print_info "Installing Python3..."
    sudo apt-get install -y python3 python3-pip python3-venv
    print_success "Python3 installed"
fi

# Install ripgrep (for Telescope grep)
if ! check_command rg; then
    print_info "Installing ripgrep..."
    sudo apt-get install -y ripgrep
    print_success "ripgrep installed"
fi

# Install fd-find (for Telescope file finding)
if ! check_command fd; then
    print_info "Installing fd-find..."
    sudo apt-get install -y fd-find
    # Create symlink since Ubuntu calls it fdfind
    sudo ln -sf $(which fdfind) /usr/local/bin/fd
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
    fc-cache -fv
    print_success "JetBrains Mono Nerd Font installed"
else
    print_success "Nerd Font already installed"
fi

# Setup Neovim configuration
cd "$SCRIPT_DIR"
setup_config

print_success "Ubuntu installation completed!"
