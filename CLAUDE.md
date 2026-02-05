# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a Neovim configuration using **lazy.nvim** as the plugin manager. The configuration follows a modular structure:

- **init.lua**: Entry point that loads core configuration and bootstraps lazy.nvim
  - Auto-detects NVM Node.js (latest version) and adds to PATH for LSP servers
  - Auto-detects Cargo bin for tree-sitter CLI
- **lua/core/**: Core Neovim settings
  - `options.lua`: Editor options (tabs, line numbers, search behavior, etc.)
  - `keymaps.lua`: Global keybindings (leader key is Space)
  - `snippets.lua`: Diagnostic configuration, filetype detection, and autocmds
  - `dockerfile_fmt.lua`: Custom Dockerfile formatter
  - `gf_alias.lua`: Path alias transformation for `gf` command (Vite/React aliases like `@`, `@components`)
- **lua/plugins/**: Each plugin has its own file with configuration
  - Plugins are loaded via `require()` statements in init.lua
  - Each plugin file returns a lazy.nvim plugin spec table

### Plugin Management Pattern

All plugins follow the lazy.nvim spec format:
```lua
return {
  'author/plugin-name',
  dependencies = { ... },
  config = function()
    -- plugin setup
  end,
}
```

### LSP Architecture

LSP setup uses the modern Neovim 0.11+ API pattern:
- `vim.lsp.config()` to configure each server
- `vim.lsp.enable()` to activate it
- Mason installs LSP servers, formatters, and linters
- LSP keybindings are set in an `LspAttach` autocommand (lua/plugins/lsp.lua:33)

**Important LSP Servers Configured:**
- TypeScript: `ts_ls`
- Python: `pyright` (auto-imports only) + `ruff` (diagnostics/linting/formatting)
- Lua: `lua_ls` (configured for Neovim development)
- Go: `gopls`
- Web: `html`, `cssls`, `tailwindcss`, `jsonls`, `yamlls`, `emmet_ls`
- Django: `django-template-lsp` for Django templates (htmldjango files)
- Infrastructure: `dockerls`, `sqls`

**Python Auto-Import Feature:**

Auto-imports work in two ways:

**1. Automatic (While Typing):**
- Type any Python symbol (e.g., `reverse_lazy`)
- Completions appear automatically with import suggestions
- Select from the menu and the import is automatically added at the top
- Shows all available modules if the symbol exists in multiple places

**2. Manual (For Existing Code):**
1. Put cursor on the undefined symbol (e.g., `reverse_lazy`)
2. Press `<leader>ci` (Space + c + i)
3. Completion menu appears with import suggestions from all available modules
4. Navigate with `<Tab>` or `<C-n>`, confirm with `<Enter>` or `<C-y>`
5. Import is automatically added at the top of the file

**How it works:**
- `<leader>ci` deletes and retypes the last character to trigger completion
- This shows Pyright's auto-import suggestions for the symbol under cursor
- Works in normal mode (cursor on word) or insert mode (while typing)
- **Note**: Only Ruff handles diagnostics - Pyright diagnostics are disabled

### Formatting & Linting

The config uses **none-ls** (null-ls successor) for formatting:
- Manual formatting via `<leader>lf` keymap (lua/plugins/lsp.lua:77-100)
- Auto-format on save is DISABLED by default
- Python: uses Ruff for both formatting and import sorting (via LSP code action)
- Lua: uses stylua
- Shell scripts: uses shfmt with 4-space indentation
- Web files: uses prettier (JS, TS, CSS, HTML, JSON, YAML, Markdown, GraphQL, Vue, Svelte)
- Django templates: uses djlint with 2-space indentation
- Go: uses gofmt + goimports
- Rust: uses rustfmt
- C/C++: uses clang-format
- Dockerfile: custom formatter (lua/core/dockerfile_fmt.lua)

**Note**: Django templates (htmldjango) automatically use 2-space tabs (configured in lua/core/snippets.lua:50-60)

**To format current buffer:** `<leader>lf` (Space + lf)

### Template Detection

Jinja2 and Django templates are automatically detected:
- Files with `.jinja`, `.jinja2`, `.j2` extensions are set to `htmldjango`
- HTML files containing `{% %}`, `{{ }}`, or `{# #}` patterns are auto-detected as `htmldjango`
- Detection logic in lua/core/snippets.lua:62-89

### LaTeX Settings

LaTeX files (`.tex`, `.latex`, `.plaintex`) have special settings:
- Line wrapping enabled with word boundaries
- Spell checking enabled (en_us)
- Configured in lua/core/snippets.lua:91-103

## Installation System

The configuration includes automated installation scripts for multiple operating systems. These scripts handle all dependencies and setup automatically.

### Supported Operating Systems

- **Ubuntu 24.04** - Uses PPA for latest Neovim
- **Debian 13** - Downloads Neovim from GitHub releases
- **LMDE 6** - Downloads Neovim from GitHub releases (Linux Mint Debian Edition)
- **macOS** - Uses Homebrew for all installations
- **Rocky Linux 9** - Uses dnf/EPEL repositories

### Installation Architecture

**Main Entry Point:** `install.sh`
- Detects operating system automatically
- Routes to appropriate OS-specific script
- Provides colored output and error handling
- Shows next steps after completion

**OS-Specific Scripts:** `scripts/install-{os}.sh`
- Ubuntu: `scripts/install-ubuntu.sh`
- Debian: `scripts/install-debian.sh`
- LMDE: `scripts/install-lmde.sh`
- macOS: `scripts/install-macos.sh`
- Rocky: `scripts/install-rocky.sh`

**Shared Functions:** `scripts/common.sh`
- `check_command()` - Verifies if a command exists
- `check_neovim_version()` - Ensures Neovim 0.10+
- `backup_existing_config()` - Creates timestamped backup
- `setup_config()` - Symlinks or copies config to ~/.config/nvim
- Print helpers: `print_info()`, `print_success()`, `print_error()`, `print_warning()`

### What Gets Installed

**Core Requirements:**
- Neovim 0.10.2+ (latest stable)
- Node.js 20.x (for LSP servers)
- Python 3 with pip (for Python LSP servers)
- Git (for version control)

**Development Tools:**
- ripgrep (for Telescope grep search)
- fd (for Telescope file finding)
- lazygit (optional Git TUI)

**Visual:**
- JetBrains Mono Nerd Font (for icons)

**Automatic After Neovim Launch:**
- All plugins via lazy.nvim
- All LSP servers via Mason (pyright, pylsp, ruff, ts_ls, lua_ls, gopls, etc.)
- All formatters via Mason (stylua, prettier, djlint, shfmt, etc.)

### Installation Behavior

**Backup Strategy:**
- If `~/.config/nvim` already exists and is not this repository, it's backed up to `~/.config/nvim.backup.YYYYMMDD_HHMMSS`
- No files are overwritten without backup

**Configuration Setup:**
- If running from `~/.config/nvim`: No action needed (already in place)
- If running from elsewhere: Creates symlink to `~/.config/nvim` (or copies if permissions don't allow symlink)

**Idempotent Design:**
- Safe to run multiple times
- Skips already-installed dependencies
- Shows status for each step

### First Launch After Installation

When you first start Neovim after installation:

1. **Lazy.nvim** automatically installs all plugins (1-2 minutes)
2. **Mason** automatically installs all LSP servers and tools (2-5 minutes)
3. Some errors during first launch are normal - close and reopen Neovim
4. Run `:checkhealth` to verify everything is working

### Quick Reference

```bash
# Clone and install
git clone <your-repo-url> ~/.config/nvim
cd ~/.config/nvim
chmod +x install.sh
./install.sh

# After installation
nvim  # First launch will install plugins and LSP servers
```

### OS-Specific Notes

**Ubuntu:**
- Uses unstable PPA for latest Neovim
- fd-find binary is named `fdfind`, symlinked to `fd`

**Debian:**
- Downloads Neovim from GitHub (repos have older versions)
- May download ripgrep from GitHub if not in repos
- fd-find binary is named `fdfind`, symlinked to `fd`

**LMDE 6:**
- Downloads Neovim from GitHub (repos have older versions)
- Uses stable Debian-based repositories
- fd-find binary is named `fdfind`, symlinked to `fd`
- Automatically detects LMDE vs regular Linux Mint

**macOS:**
- Installs Homebrew if not present
- Adds Homebrew to PATH for Apple Silicon Macs
- Installs Nerd Font via cask
- Reminder to configure terminal font

**Rocky Linux:**
- Enables EPEL and CRB repositories
- Downloads Neovim from GitHub
- Installs Development Tools group
- Uses NodeSource for Node.js

## Development Commands

### Formatting Lua Files
```bash
stylua --check .
stylua .
```

Configuration is in `.stylua.toml`:
- 2 spaces indentation
- Single quotes preferred
- No call parentheses
- 160 column width

### Plugin Management
Inside Neovim:
- `:Lazy` - Open lazy.nvim plugin manager UI
- `:Lazy sync` - Install/update/clean plugins
- `:Lazy update` - Update all plugins
- `:Mason` - Open Mason installer for LSP servers and tools

### LSP & Diagnostics
- `:LspInfo` - Show active LSP clients
- `:LspRestart` - Restart LSP clients
- `:Mason` - Install/manage LSP servers, formatters, linters

### Treesitter
- `:TSUpdate` - Update all parsers
- `:TSInstall <language>` - Install a specific parser

## Key Architectural Decisions

1. **Lazy loading:** Plugins are loaded on-demand where possible (e.g., Telescope loads on `VimEnter`)

2. **LSP keybindings:** All LSP-specific keybindings are defined in the `LspAttach` autocommand, so they only apply when an LSP is active

3. **Completion sources:** nvim-cmp uses multiple sources in priority order:
   - lazydev (Lua Neovim API, group_index=0)
   - LSP completions
   - LuaSnip snippets
   - Buffer text
   - File paths
   - Completions can be confirmed with `<C-y>` or `<Enter>`

4. **Manual formatting:** Formatting is manual only via `<leader>lf` keymap (auto-format on save is disabled)

5. **Diagnostics:** Configured to show inline virtual text with error codes, no underlines, and updates in insert mode

6. **Code folding:** Uses Treesitter for syntax-aware folding with all folds open by default (foldlevel=99)

## Keymap Reference

**Leader Key**: `Space`

### General
- `<leader>wn` - Write file without formatting

### Window Management
- `<leader>v` - Split window vertically
- `<leader>h` - Split window horizontally
- `<leader>se` - Make splits equal size
- `<leader>xs` - Close current split
- `<Up>/<Down>/<Left>/<Right>` - Resize window

### Navigation
- `<C-k>/<C-j>/<C-h>/<C-l>` - Move between splits
- `<Tab>/<S-Tab>` - Next/previous buffer

### Buffers
- `<leader>bx` - Close buffer
- `<leader>ba` - Close all buffers except current
- `<leader>bo` - New buffer

### Tabs
- `<leader>to` - Open new tab
- `<leader>tx` - Close current tab
- `<leader>ta` - Close all tabs except current
- `<leader>tn` - Next tab
- `<leader>tp` - Previous tab

### File Explorer (Neotree)
- `<leader>e` - Toggle file explorer
- `<leader>ngs` - Open git status window
- `\` - Reveal current file in explorer

### Telescope (Fuzzy Finder)
- `<leader>sf` - Search files
- `<leader>sg` - Search by grep (live)
- `<leader>sw` - Search current word
- `<leader>sh` - Search help
- `<leader>sk` - Search keymaps
- `<leader>sd` - Search diagnostics
- `<leader>sr` - Search resume
- `<leader>s.` - Search recent files
- `<leader>sn` - Search Neovim config files
- `<leader><leader>` - Find existing buffers
- `<leader>/` - Search in current buffer
- `<leader>s/` - Search in open files

### LSP (when LSP is active)
- `gd` - Go to definition
- `gr` - Go to references
- `gI` - Go to implementation
- `gD` - Go to declaration
- `<leader>D` - Type definition
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code action
- `<leader>ci` - Trigger import suggestions (shows completion menu with auto-imports)
- `<leader>ds` - Document symbols
- `<leader>ws` - Workspace symbols
- `<leader>th` - Toggle inlay hints

### Formatting
- `<leader>lf` - Format current buffer

### Diagnostics
- `[d` - Go to previous diagnostic
- `]d` - Go to next diagnostic
- `<leader>dd` - Open floating diagnostic
- `<leader>q` - Open diagnostics list

### Editing
- `<leader>lw` - Toggle line wrapping
- `<` / `>` (visual mode) - Indent left/right and reselect
- `<C-/>` or `<C-c>` - Toggle comment (normal/visual mode)

### Folding
- `<leader>za` - Toggle fold at cursor
- `<leader>zM` - Close all folds
- `<leader>zR` - Open all folds
- `<leader>zo` - Open fold at cursor
- `<leader>zc` - Close fold at cursor
- `zj` - Move to next fold
- `zk` - Move to previous fold

### Claude Code
- `<leader>cc` - Toggle Claude Code

### Background
- `<leader>bg` - Toggle background transparency

## File Location Conventions

- Custom snippets/autocmds: Add to `lua/core/snippets.lua`
- New plugins: Create `lua/plugins/<name>.lua` and require it in `init.lua`
- Global keymaps: Add to `lua/core/keymaps.lua`
- Plugin-specific keymaps: Define in the plugin's config function

## Testing Configuration Changes

1. **Reload config:** Restart Neovim or use `:source $MYVIMRC` (though some changes may require a full restart)
2. **Check for errors:** `:messages` shows recent errors
3. **Verify plugins:** `:Lazy` shows plugin status
4. **Test LSP:** Open a file and run `:LspInfo` to verify server attached

## Troubleshooting Guide

### LSP Server Not Starting

**Symptoms:**
- LSP features (go to definition, diagnostics, etc.) not working
- `:LspInfo` shows server not attached or errors like "not executable"

**Solutions:**
1. Check Mason installation status:
   ```vim
   :Mason
   ```
   Verify the LSP server is installed (green checkmark). If not, restart Neovim to trigger auto-installation.

2. Check LSP logs for specific errors:
   ```vim
   :LspLog
   ```
   Look for error messages related to the server.

3. Manually install via Mason:
   - Open `:Mason`
   - Search for the server (e.g., type `/pyright`)
   - Press `i` to install

4. Restart LSP client after installation:
   ```vim
   :LspRestart
   ```

**Note:** All LSP servers configured in `lua/plugins/lsp.lua` (in the `servers` table) are automatically added to Mason's auto-install list. They should install on first Neovim startup.

### Auto-Import Not Working (Python)

**Symptoms:**
- Typing `reverse_lazy` doesn't show import suggestions
- `<leader>ci` keymap doesn't trigger import menu
- Completions appear but without import options

**Solutions:**
1. Verify pyright is installed and running:
   ```vim
   :LspInfo
   ```
   You should see `pyright` in the list of attached clients for Python files.

2. If pyright is missing:
   - Run `:Mason` and check if pyright is installed
   - If not installed, restart Neovim to trigger auto-installation
   - Or manually install: `:Mason` → search "pyright" → press `i`

3. Test manual typing:
   - Type an incomplete symbol like `reverse_laz`
   - Completion menu should appear automatically with import suggestions
   - If this works, but `<leader>ci` doesn't, the issue is with the keymap

4. Check pyright configuration in `lua/plugins/lsp.lua:226-243`:
   - `autoImportCompletions` should be `true`
   - `diagnosticMode` should be `'off'` (only Ruff handles diagnostics)

5. Verify nvim-cmp is receiving LSP completions:
   - Check that `nvim_lsp` is in the sources list at `lua/plugins/autocompletion.lua:149-159`

### Completions Not Triggering

**Symptoms:**
- No automatic completions while typing
- Completion menu doesn't appear at all

**Solutions:**

1. **Verify LSP is attached**:
   ```vim
   :LspInfo
   ```
   You should see LSP clients attached (e.g., `pyright`, `pylsp`, `ruff` for Python)

2. **Test automatic completions**:
   - Type a partial word like `pri` in a Python file
   - Wait a moment - completions should appear automatically
   - If they don't, continue troubleshooting below

3. **Check nvim-cmp is loaded**:
   ```vim
   :Lazy
   ```
   Look for `nvim-cmp` - should show as loaded (not lazy)

4. **Verify completion sources**:
   - Check `lua/plugins/autocompletion.lua:149-159`
   - Should include `nvim_lsp`, `luasnip`, `buffer`, and `path`

5. **Check for errors**:
   ```vim
   :messages
   ```
   Look for any errors related to nvim-cmp or LSP

6. **Restart LSP clients**:
   ```vim
   :LspRestart
   ```

### Formatting Not Working

**Symptoms:**
- `<leader>lf` doesn't format the file
- Unexpected formatting behavior

**Solutions:**
1. Check if none-ls is attached:
   ```vim
   :LspInfo
   ```
   You should see `null-ls` in the attached clients list.

2. Verify the formatter is installed in Mason:
   ```vim
   :Mason
   ```
   Look for formatters like `ruff`, `stylua`, `prettier`, etc.

3. Check none-ls sources in `lua/plugins/none-ls.lua:27-75`

4. Restart LSP:
   ```vim
   :LspRestart
   ```

5. Check if the file type is supported by looking at the `filetypes` configuration for each formatter

### Django Template LSP Issues

**Symptoms:**
- No LSP features in `.html` Django template files
- Errors about "cmd: expected function or table"

**Solutions:**
1. Ensure file is detected as `htmldjango`:
   ```vim
   :set filetype?
   ```
   Should show `filetype=htmldjango`. If not, add a modeline or configure filetype detection.

2. Check if django-template-lsp is installed:
   ```vim
   :Mason
   ```

3. Verify the LSP configuration in `lua/plugins/lsp.lua:246-256`

### Plugin Installation Issues

**Symptoms:**
- Plugins not loading
- Missing plugin features

**Solutions:**
1. Open Lazy plugin manager:
   ```vim
   :Lazy
   ```

2. Install/update all plugins:
   ```vim
   :Lazy sync
   ```

3. Check for errors in the Lazy UI (red `x` marks)

4. Try cleaning and reinstalling:
   ```vim
   :Lazy clean
   :Lazy sync
   ```

5. Check for errors:
   ```vim
   :messages
   ```

### General Debugging Steps

1. **Check messages:** `:messages` shows all recent errors and warnings
2. **Check LSP status:** `:LspInfo` shows attached servers and their status
3. **Check LSP logs:** `:LspLog` shows detailed LSP communication logs
4. **Restart Neovim:** Many changes require a full restart
5. **Verify file in git repo:** Some features may behave differently outside git repositories
6. **Check Treesitter:** `:TSInstall <language>` or `:TSUpdate` for syntax highlighting issues
