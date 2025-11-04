# Neovim Configuration

A modern, feature-rich Neovim configuration with LSP support, auto-completion, and auto-import functionality.

## Features

- **LSP Support**: Full Language Server Protocol support for multiple languages
- **Auto-Import**: Automatic import suggestions for Python (via Pyright)
- **Auto-Completion**: Intelligent code completion with nvim-cmp
- **Syntax Highlighting**: TreeSitter-based syntax highlighting
- **Fuzzy Finding**: Telescope for file and text searching
- **File Explorer**: Neo-tree for file navigation
- **Git Integration**: Gitsigns for git integration
- **Formatting**: Automatic code formatting with none-ls
- **Django Support**: Django template LSP and formatting

### Supported Languages

- Python (Pyright, Pylsp, Ruff)
- TypeScript/JavaScript (ts_ls)
- Lua (lua_ls)
- Go (gopls)
- HTML/CSS/Tailwind
- Django Templates
- Docker, SQL, Terraform, YAML, JSON

## Installation

### To remove old

```bash
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
```

### Automated Installation

The installation script will automatically:
- Install Neovim (latest version)
- Install all required dependencies
- Install a Nerd Font for icons
- Set up the configuration

#### Supported Operating Systems

- **Ubuntu 24.04**
- **Debian 13**
- **macOS**
- **Rocky Linux 9**

### Quick Install

```bash
# Clone this repository
git clone <your-repo-url> ~/.config/nvim

# Run the installation script
cd ~/.config/nvim
chmod +x install.sh
./install.sh
```

The script will automatically detect your operating system and install all necessary dependencies.

### Manual Installation

If you prefer to install manually or the script doesn't work for your system:

#### Prerequisites

1. **Neovim 0.10+**
   ```bash
   # Check version
   nvim --version
   ```

2. **Node.js** (for LSP servers)
   ```bash
   node --version
   ```

3. **Python 3** with pip
   ```bash
   python3 --version
   ```

4. **Git**
   ```bash
   git --version
   ```

5. **ripgrep** (for Telescope grep)
   ```bash
   rg --version
   ```

6. **fd** (for Telescope file finding)
   ```bash
   fd --version
   ```

7. **A Nerd Font** (for icons)
   - Download from: https://www.nerdfonts.com/
   - Recommended: JetBrains Mono Nerd Font

#### Setup Steps

1. Clone or copy this configuration to `~/.config/nvim`
2. Install dependencies for your OS (see OS-specific sections below)
3. Start Neovim: `nvim`
4. Lazy.nvim will automatically install plugins
5. Mason will automatically install LSP servers
6. Run `:checkhealth` to verify everything works

## First Launch

When you first launch Neovim:

1. **Lazy.nvim** will automatically install all plugins (takes 1-2 minutes)
2. **Mason** will automatically install LSP servers and tools (takes 2-5 minutes)
3. You may see some errors during the first launch - this is normal
4. Close and reopen Neovim after installation completes

### Verify Installation

```vim
:checkhealth
```

This will show you if anything is missing or misconfigured.

## Key Features Usage

### Auto-Import (Python)

#### Automatic (while typing):
1. Type any Python symbol (e.g., `reverse_lazy`)
2. Completions appear automatically with import suggestions
3. Select from the menu and the import is added automatically

#### Manual (for existing code):
1. Put cursor on undefined symbol (e.g., `reverse_lazy`)
2. Press `<leader>ci` (Space + c + i)
3. Select import from completion menu
4. Import is automatically added at top of file

### Key Mappings

**Leader Key**: `Space`

#### General
- `<leader>wn` - Write file without formatting
- `<leader>e` - Toggle file explorer
- `<leader>sf` - Search files
- `<leader>sg` - Live grep

#### LSP
- `gd` - Go to definition
- `gr` - Go to references
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `<leader>ci` - Trigger import suggestions
- `<leader>lf` - Format current buffer

#### Completion
- `<C-n>` / `<C-p>` - Next/previous completion
- `<Tab>` - Select next completion
- `<Enter>` or `<C-y>` - Confirm completion

See `CLAUDE.md` for complete keymap reference.

## Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── core/
│   │   ├── options.lua      # Editor options
│   │   ├── keymaps.lua      # Global keymaps
│   │   └── snippets.lua     # Diagnostics & autocmds
│   └── plugins/
│       ├── lsp.lua          # LSP configuration
│       ├── autocompletion.lua # Completion setup
│       ├── none-ls.lua      # Formatting
│       ├── telescope.lua    # Fuzzy finder
│       ├── treesitter.lua   # Syntax highlighting
│       └── ...
├── scripts/
│   ├── install-ubuntu.sh    # Ubuntu installer
│   ├── install-debian.sh    # Debian installer
│   ├── install-macos.sh     # macOS installer
│   ├── install-rocky.sh     # Rocky Linux installer
│   └── common.sh            # Shared functions
├── install.sh               # Main installer
├── CLAUDE.md                # Detailed documentation
└── README.md                # This file
```

## Troubleshooting

### LSP not working

```vim
:LspInfo
```

Check if LSP servers are attached. If not:

```vim
:Mason
```

Ensure required servers are installed.

### Completions not appearing

1. Verify nvim-cmp is loaded: `:Lazy`
2. Check LSP is attached: `:LspInfo`
3. Restart LSP: `:LspRestart`

### Auto-import not working

1. Verify pyright is installed: `:Mason`
2. Check pyright is running: `:LspInfo`
3. Test by typing incomplete symbol

### Icons not showing

Install a Nerd Font and configure your terminal to use it.

See `CLAUDE.md` for detailed troubleshooting guide.

## Updating

### Update Plugins

```vim
:Lazy update
```

### Update LSP Servers

```vim
:Mason
```

Press `U` to update all packages.

### Update Configuration

```bash
cd ~/.config/nvim
git pull
```

Restart Neovim after updating.

## Customization

### Adding LSP Servers

Edit `lua/plugins/lsp.lua` and add to the `servers` table:

```lua
servers = {
  your_server = {},
  -- ... other servers
}
```

Servers are auto-installed via Mason.

### Adding Keymaps

Edit `lua/core/keymaps.lua`:

```lua
vim.keymap.set('n', '<leader>xx', ':Command<CR>', {
  noremap = true,
  silent = true,
  desc = 'Description'
})
```

### Changing Theme

Edit `lua/plugins/gruvbox.lua` or install a different theme plugin.

## Uninstallation

```bash
# Backup first if needed
mv ~/.config/nvim ~/.config/nvim.backup

# Remove data directories
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
```

## Documentation

- **CLAUDE.md** - Comprehensive documentation with architecture details
- **:help** - Neovim built-in help
- Individual plugin documentation in respective files

## Credits

This configuration uses:
- [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP configuration
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) - Completion engine
- [Telescope](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy finder
- [Neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim) - File explorer
- [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Syntax highlighting
- And many more amazing plugins!

## License

This configuration is provided as-is for personal use.
