return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    { 'mason-org/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
    -- mason-lspconfig:
    -- - Bridges the gap between LSP config names (e.g. "lua_ls") and actual Mason package names (e.g. "lua-language-server").
    -- - Used here only to allow specifying language servers by their LSP name (like "lua_ls") in `ensure_installed`.
    -- - It does not auto-configure servers — we use vim.lsp.config() + vim.lsp.enable() explicitly for full control.
    'mason-org/mason-lspconfig.nvim',
    -- mason-tool-installer:
    -- - Installs LSPs, linters, formatters, etc. by their Mason package name.
    -- - We use it to ensure all desired tools are present.
    -- - The `ensure_installed` list works with mason-lspconfig to resolve LSP names like "lua_ls".
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Useful status updates for LSP.
    {
      'j-hui/fidget.nvim',
      opts = {
        notification = {
          window = {
            winblend = 0, -- Background color opacity in the notification window
          },
        },
      },
    },

    -- Allows extra capabilities provided by nvim-cmp
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        -- Create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-t>.
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

        -- Find references for the word under your cursor.
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

        -- Fuzzy find all the symbols in your current workspace.
        --  Similar to document symbols, except searches over your entire project.
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- Rename the variable under your cursor.
        --  Most Language Servers support renaming across iles, etc.
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

        -- Universal format: organize imports (if available) + format
        map('<leader>lf', function()
          local ft = vim.bo.filetype

          -- Dockerfile: use custom formatter
          if ft == 'dockerfile' then
            require('core.dockerfile_fmt').format()
            return
          end

          -- Python: organize imports first, then format
          if ft == 'python' then
            vim.lsp.buf.code_action {
              context = { only = { 'source.organizeImports' } },
              apply = true,
            }
            vim.defer_fn(function()
              vim.lsp.buf.format { async = false }
            end, 100)
            return
          end

          -- All other filetypes: just format
          vim.lsp.buf.format { async = false }
        end, '[L]SP [F]ormat')

        -- Trigger import suggestions for the symbol under cursor
        -- Works by simulating typing: delete last char and retype it to trigger nvim-cmp
        -- This shows Pyright's auto-import completions for existing undefined symbols
        map('<leader>ci', function()
          local mode = vim.api.nvim_get_mode().mode

          -- Move to end of word if in normal mode
          if mode == 'n' then
            vim.cmd 'normal! e'
          end

          -- Get the last character of the word to retype it
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local last_char = line:sub(col + 1, col + 1) -- col is 0-based, Lua strings are 1-based

          -- Simulate typing by backspacing and retyping the last character
          local keys
          if mode == 'n' then
            keys = vim.api.nvim_replace_termcodes('a<BS>' .. last_char, true, false, true)
          else
            keys = vim.api.nvim_replace_termcodes('<BS>' .. last_char, true, false, true)
          end
          vim.api.nvim_feedkeys(keys, 'n', false)

          -- Trigger completion menu after the simulated typing
          vim.schedule(function()
            require('cmp').complete()
          end)
        end, '[C]ode [I]mport')

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- The following code creates a keymap to toggle inlay hints in your
        -- code, if the language server you are using supports them
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- LSP servers and clients are able to communicate to each other what features they support.
    -- By default, Neovim doesn't support everything that is in the LSP specification.
    -- When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
    -- So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    -- Enable the following language servers
    --
    -- Add any additional override configuration in the following tables. Available keys are:
    -- - cmd (table): Override the default command used to start the server
    -- - filetypes (table): Override the default list of associated filetypes for the server
    -- - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
    -- - settings (table): Override the default settings passed when initializing the server.
    local servers = {
      ts_ls = {},
      ruff = {
        init_options = {
          settings = {
            -- Linting settings
            lint = {
              enable = true,
              -- Best practice rule selection
              select = {
                'F', -- Pyflakes (errors, undefined names, etc.)
                'E', -- pycodestyle errors
                'W', -- pycodestyle warnings
                'I', -- isort (import sorting)
                'B', -- flake8-bugbear (bug detection)
                'UP', -- pyupgrade (modern Python syntax)
                'N', -- pep8-naming
                'SIM', -- flake8-simplify
                'RUF', -- Ruff-specific rules
              },
              -- Ignore specific rules if needed
              ignore = {
                'E501', -- Line too long (handled by formatter)
              },
            },
            -- Formatting settings
            format = {
              preview = true,
            },
            -- Code actions
            fixAll = true,
            organizeImports = true,
            -- Line length (match Black's default)
            lineLength = 88,
          },
        },
      },
      pyright = {
        -- Pyright only for IDE features: auto-imports, go-to-definition, hover, references
        -- All diagnostics handled by Ruff
        capabilities = {
          textDocument = {
            publishDiagnostics = {
              tagSupport = { valueSet = {} },
            },
          },
        },
        settings = {
          pyright = {
            disableOrganizeImports = true, -- Ruff handles this
          },
          python = {
            analysis = {
              autoImportCompletions = true,
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'off',
              typeCheckingMode = 'off',
            },
          },
        },
      },
      -- pylsp removed - Ruff + Pyright cover all features
      html = { filetypes = { 'html', 'twig', 'hbs' } },
      ['django-template-lsp'] = {
        filetypes = { 'htmldjango' },
        settings = {
          django = {
            -- Auto-discover Django project settings
            enabled = true,
            -- Paths to Django project roots (optional, auto-detected if not set)
            -- projects = {},
          },
        },
      },
      cssls = {},
      tailwindcss = {},
      dockerls = {},
      sqlls = {},
      terraformls = {},
      gopls = {},
      jsonls = {},
      yamlls = {},
      emmet_ls = {
        filetypes = {
          'html',
          'htmldjango',
          'css',
          'scss',
          'less',
          'javascript',
          'javascriptreact',
          'typescript',
          'typescriptreact',
          'vue',
          'svelte',
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            runtime = { version = 'LuaJIT' },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file('', true),
            },
            diagnostics = {
              globals = { 'vim' },
              disable = { 'missing-fields' },
            },
            format = {
              enable = false,
            },
          },
        },
      },
    }

    -- Ensure the servers and tools above are installed
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua', -- Used to format Lua code
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    for server, cfg in pairs(servers) do
      -- For each LSP server (cfg), we merge:
      -- 1. A fresh empty table (to avoid mutating capabilities globally)
      -- 2. Your capabilities object with Neovim + cmp features
      -- 3. Any server-specific cfg.capabilities if defined in `servers`
      cfg.capabilities = vim.tbl_deep_extend('force', {}, capabilities, cfg.capabilities or {})

      vim.lsp.config(server, cfg)
      vim.lsp.enable(server)
    end
  end,
}
