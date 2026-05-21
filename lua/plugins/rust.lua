-- State-of-the-art Rust development setup
-- Combines: rustaceanvim (rust-analyzer + test lens + runnables + debug),
-- crates.nvim (Cargo.toml package management)

return {
  -- ────────────────────────────────────────────────────────────
  -- rustaceanvim — rust-analyzer LSP + test lens + runnables + debug
  -- Successor to the deprecated rust-tools.nvim. Auto-attaches to
  -- rust buffers; DO NOT also configure rust_analyzer via lspconfig.
  -- ────────────────────────────────────────────────────────────
  {
    'mrcjkb/rustaceanvim',
    version = '^6',
    lazy = false, -- plugin is already lazy via ftplugin
    ft = { 'rust' },
    init = function()
      vim.g.rustaceanvim = {
        -- Plugin configuration
        tools = {
          -- Floating window border
          float_win_config = { border = 'rounded' },
          -- Auto-focus the hover actions window
          hover_actions = { auto_focus = false },
          -- Show test results in a split (not floating)
          test_executor = 'background',
        },
        -- LSP configuration (rust-analyzer)
        server = {
          on_attach = function(client, bufnr)
            -- Rust-specific keymaps (the global LspAttach already wires
            -- up gd/gr/<leader>ca/<leader>rn/<leader>lf/etc.)
            local map = function(lhs, rhs, desc)
              vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = '[Rust] ' .. desc })
            end
            -- Code actions / hover (rustaceanvim's enhanced versions)
            map('<leader>ra', function() vim.cmd.RustLsp 'codeAction' end, 'Code [A]ction')
            map('K', function() vim.cmd.RustLsp { 'hover', 'actions' } end, 'Hover actions')
            -- Runnables / testables (test lens equivalents)
            map('<leader>rr', function() vim.cmd.RustLsp 'runnables' end, '[R]unnables')
            map('<leader>rt', function() vim.cmd.RustLsp 'testables' end, '[T]estables')
            map('<leader>rT', function() vim.cmd.RustLsp { 'testables', bang = true } end, 'Re-run last [T]est')
            -- Expand macro under cursor
            map('<leader>rm', function() vim.cmd.RustLsp 'expandMacro' end, 'Expand [M]acro')
            -- Open Cargo.toml from any rust file
            map('<leader>rC', function() vim.cmd.RustLsp 'openCargo' end, 'Open [C]argo.toml')
            -- Parent module
            map('<leader>rp', function() vim.cmd.RustLsp 'parentModule' end, '[P]arent module')
            -- Explain the error under the cursor
            map('<leader>re', function() vim.cmd.RustLsp 'explainError' end, '[E]xplain error')
            -- Render diagnostic (full rustc error)
            map('<leader>rd', function() vim.cmd.RustLsp 'renderDiagnostic' end, 'Render [D]iagnostic')
            -- Debuggables (requires codelldb installed via Mason)
            map('<leader>rD', function() vim.cmd.RustLsp 'debuggables' end, '[D]ebuggables')
          end,
          default_settings = {
            -- rust-analyzer language server configuration
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = { enable = true },
              },
              -- Use clippy for diagnostics on save
              checkOnSave = true,
              check = {
                command = 'clippy',
                extraArgs = { '--no-deps' },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ['async-trait'] = { 'async_trait' },
                  ['napi-derive'] = { 'napi' },
                  ['async-recursion'] = { 'async_recursion' },
                },
              },
              -- Inlay hints (toggle with <leader>th from the global LspAttach)
              inlayHints = {
                bindingModeHints = { enable = false },
                chainingHints = { enable = true },
                closingBraceHints = { enable = true, minLines = 25 },
                closureReturnTypeHints = { enable = 'never' },
                lifetimeElisionHints = { enable = 'never', useParameterNames = false },
                maxLength = 25,
                parameterHints = { enable = true },
                reborrowHints = { enable = 'never' },
                renderColons = true,
                typeHints = {
                  enable = true,
                  hideClosureInitialization = false,
                  hideNamedConstructor = false,
                },
              },
              -- Code lenses (run | debug | test above functions — VSCode "Test lens")
              lens = {
                enable = true,
                run = { enable = true },
                debug = { enable = true },
                implementations = { enable = true },
                references = {
                  adt = { enable = false },
                  enumVariant = { enable = false },
                  method = { enable = false },
                  trait = { enable = false },
                },
              },
              completion = {
                autoimport = { enable = true },
                postfix = { enable = true },
              },
              imports = {
                granularity = { group = 'module' },
                prefix = 'self',
              },
            },
          },
        },
        -- DAP configuration (used by <leader>rD). Picks up codelldb
        -- installed via Mason automatically when present.
        dap = {},
      }
    end,
  },

  -- ────────────────────────────────────────────────────────────
  -- crates.nvim — Cargo.toml version completion, upgrade actions
  -- ────────────────────────────────────────────────────────────
  {
    'saecki/crates.nvim',
    tag = 'stable',
    event = { 'BufRead Cargo.toml' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('crates').setup {
        completion = {
          cmp = { enabled = true },
          crates = {
            enabled = true,
            max_results = 8,
            min_chars = 3,
          },
        },
        lsp = {
          enabled = true,
          on_attach = function(_, bufnr)
            local map = function(lhs, rhs, desc)
              vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = '[Crates] ' .. desc })
            end
            local crates = require 'crates'
            map('<leader>cu', crates.update_crate, '[U]pdate crate')
            map('<leader>cU', crates.upgrade_crate, '[U]pgrade crate (latest)')
            map('<leader>cM', crates.update_all_crates, 'Update all crates')
            map('<leader>cP', crates.upgrade_all_crates, 'Upgrade all crates (latest)')
            map('<leader>cH', crates.open_homepage, '[H]omepage')
            map('<leader>cR', crates.open_repository, '[R]epository')
            map('<leader>cD', crates.open_documentation, '[D]ocumentation')
            map('<leader>cv', crates.show_versions_popup, '[V]ersions popup')
            map('<leader>cf', crates.show_features_popup, '[F]eatures popup')
            map('<leader>cd', crates.show_dependencies_popup, '[D]ependencies popup')
          end,
          actions = true,
          completion = true,
          hover = true,
        },
      }
    end,
  },
}
