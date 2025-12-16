#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/scripts/common.sh"

print_info "Installing dependencies for LMDE 6..."

# Update package list
print_info "Updating package list..."
sudo apt-get update

# Install build essentials
print_info "Installing build essentials..."
sudo apt-get install -y build-essential curl wget git unzip libreadline-dev

# Install Neovim from GitHub releases (LMDE repos may have older versions)
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
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_success "Node.js installed"
fi

# Install Python and pip (ensure venv is always installed for Mason)
print_info "Installing Python3 and venv..."
sudo apt-get install -y python3 python3-pip python3-venv
print_success "Python3 and venv installed"

# Install Go (for gopls, goimports, gofmt)
if ! check_command go; then
    print_info "Installing Go..."
    GO_VERSION="1.23.4"
    wget -q "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
    rm "go${GO_VERSION}.linux-amd64.tar.gz"
    # Add to PATH for current session
    export PATH=$PATH:/usr/local/go/bin
    # Detect shell and add to appropriate rc file
    SHELL_RC=""
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == */zsh ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == */bash ]]; then
        SHELL_RC="$HOME/.bashrc"
    fi
    if [[ -n "$SHELL_RC" ]] && [[ -f "$SHELL_RC" ]]; then
        if ! grep -q '/usr/local/go/bin' "$SHELL_RC"; then
            echo 'export PATH=$PATH:/usr/local/go/bin' >> "$SHELL_RC"
            print_info "Added Go to PATH in $SHELL_RC"
        fi
    fi
    print_success "Go installed"
fi

# Install clang-format (for C/C++ formatting)
if ! check_command clang-format; then
    print_info "Installing clang-format..."
    sudo apt-get install -y clang-format
    print_success "clang-format installed"
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
    # Create symlink since Debian-based systems call it fdfind
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
    # Install fontconfig if not present
    if ! command -v fc-cache &> /dev/null; then
        sudo apt-get install -y fontconfig
    fi
    fc-cache -fv
    print_success "JetBrains Mono Nerd Font installed"
else
    print_success "Nerd Font already installed"
fi

# Setup Neovim configuration
cd "$SCRIPT_DIR"
setup_config

print_success "LMDE 6 installation completed!"
