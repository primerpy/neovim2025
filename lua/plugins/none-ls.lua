return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvimtools/none-ls-extras.nvim',
    'jayp0521/mason-null-ls.nvim',
  },
  config = function()
    local null_ls = require 'null-ls'
    local formatting = null_ls.builtins.formatting
    local diagnostics = null_ls.builtins.diagnostics

    require('mason-null-ls').setup {
      ensure_installed = {
        'prettier', -- ts/js/html/json/yaml/markdown
        'eslint_d', -- js/ts linter
        'shfmt', -- shell formatter
        'checkmake', -- makefile linter
        'clang-format', -- c/c++ formatter
        -- rustfmt: install via rustup, not Mason (deprecated)
        'gofmt', -- go formatter
        'goimports', -- go imports
        'djlint', -- django template formatter
      },
      automatic_installation = true,
    }

    local sources = {
      -- Linters
      diagnostics.checkmake,

      -- Formatters
      formatting.prettier.with {
        filetypes = {
          'javascript',
          'javascriptreact',
          'typescript',
          'typescriptreact',
          'vue',
          'svelte',
          'css',
          'scss',
          'less',
          'html',
          'json',
          'jsonc',
          'yaml',
          'markdown',
          'graphql',
        },
      },
      formatting.djlint.with {
        filetypes = { 'htmldjango' },
        extra_args = { '--indent', '2' },
      },
      formatting.stylua,
      formatting.shfmt.with { args = { '-i', '4' } },

      -- Python formatting handled by Ruff LSP directly (see lsp.lua)

      -- C / C++
      formatting.clang_format.with {
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
        extra_args = { '--style=file' },
      },

      -- Rust (via none-ls-extras)
      require('none-ls.formatting.rustfmt').with {
        filetypes = { 'rust' },
        extra_args = { '--edition=2021' },
      },

      -- Go
      formatting.gofmt.with { filetypes = { 'go' } },
      formatting.goimports.with { filetypes = { 'go' } },
    }

    null_ls.setup {
      sources = sources,
      on_attach = function(client, bufnr)
        if client.supports_method 'textDocument/formatting' then
          -- Set up <leader>f for manual formatting
          vim.keymap.set('n', '<leader>lf', function()
            vim.lsp.buf.format { async = false }
          end, { buffer = bufnr, desc = 'Format buffer' })
        end
      end,
    }
  end,
}
