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
sudo dnf install -y curl wget git unzip readline-devel

# Install Neovim 0.11+ from GitHub releases (required for modern LSP API)
if ! check_neovim_version 11; then
    # Clean up any old Neovim installations first
    remove_old_neovim

    print_info "Installing Neovim 0.11+ from GitHub releases..."

    # Try stable releases in order of preference (latest first)
    NVIM_VERSIONS=("v0.11.5" "v0.11.4" "v0.11.3" "v0.11.2" "v0.11.1" "v0.11.0")
    DOWNLOAD_SUCCESS=false

    for NVIM_VERSION in "${NVIM_VERSIONS[@]}"; do
        DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"

        print_info "Trying Neovim ${NVIM_VERSION}..."

        if wget --spider "$DOWNLOAD_URL" 2>/dev/null; then
            print_info "Downloading from: $DOWNLOAD_URL"
            if wget -O nvim-linux64.tar.gz "$DOWNLOAD_URL"; then
                DOWNLOAD_SUCCESS=true
                break
            fi
        fi
        print_warning "Neovim ${NVIM_VERSION} not available, trying next..."
    done

    if [[ "$DOWNLOAD_SUCCESS" != "true" ]]; then
        print_error "Failed to download Neovim. Please check your internet connection."
        exit 1
    fi

    # Extract and install
    print_info "Extracting Neovim..."
    sudo rm -rf /opt/nvim-linux64  # Clean any partial extraction
    sudo mkdir -p /opt/nvim-linux64
    sudo tar -xzf nvim-linux64.tar.gz -C /opt/nvim-linux64 --strip-components=1
    sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
    rm -f nvim-linux64.tar.gz

    # Verify installation
    if command -v nvim &> /dev/null; then
        INSTALLED_VERSION=$(nvim --version | head -n1)
        print_success "Neovim installed: $INSTALLED_VERSION"
    else
        print_error "Neovim installation failed - binary not found in PATH"
        print_info "Check if /usr/local/bin is in your PATH"
        exit 1
    fi
fi

# Install Node.js (for LSP servers)
if ! check_command node; then
    print_info "Installing Node.js..."
    curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
    sudo dnf install -y nodejs
    print_success "Node.js installed"
fi

# Install Python and pip (ensure venv is always installed for Mason)
print_info "Installing Python3 and venv..."
sudo dnf install -y python3 python3-pip python3-virtualenv
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
    sudo dnf install -y clang-tools-extra
    print_success "clang-format installed"
fi

# Install Rust and rustfmt (for Rust formatting)
if ! check_command rustfmt; then
    print_info "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --component rustfmt
    # Add cargo to PATH for current session
    source "$HOME/.cargo/env"
    # Detect shell and add to appropriate rc file
    SHELL_RC=""
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == */zsh ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == */bash ]]; then
        SHELL_RC="$HOME/.bashrc"
    fi
    if [[ -n "$SHELL_RC" ]] && [[ -f "$SHELL_RC" ]]; then
        if ! grep -q '.cargo/env' "$SHELL_RC"; then
            echo '. "$HOME/.cargo/env"' >> "$SHELL_RC"
            print_info "Added Cargo to PATH in $SHELL_RC"
        fi
    fi
    print_success "Rust and rustfmt installed"
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
