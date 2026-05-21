-- State-of-the-art Go development setup
-- Combines: ray-x/go.nvim (Go commands), nvim-dap-go (Delve debugger),
-- nvim-dap-ui (debug UI), neotest-golang (test runner)

return {
  -- ────────────────────────────────────────────────────────────
  -- ray-x/go.nvim — Go-specific commands & code actions
  -- ────────────────────────────────────────────────────────────
  {
    'ray-x/go.nvim',
    dependencies = {
      'ray-x/guihua.lua', -- floating UI for refactor / code actions
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
    ft = { 'go', 'gomod', 'gosum', 'gotmpl', 'gohtmltmpl', 'gotexttmpl' },
    event = { 'CmdlineEnter' },
    build = ':lua require("go.install").update_all_sync()', -- install/update all binaries
    config = function()
      require('go').setup {
        -- Use gopls settings already configured in lsp.lua (don't override)
        lsp_cfg = false,
        lsp_keymaps = false,
        lsp_on_attach = false,
        -- Diagnostic display
        lsp_diag_hdlr = true,
        lsp_diag_virtual_text = { space = 0, prefix = '■' },
        lsp_diag_signs = true,
        lsp_diag_underline = true,
        -- Code lenses
        lsp_codelens = true,
        -- Inlay hints (via gopls)
        lsp_inlay_hints = {
          enable = true,
          only_current_line = false,
          show_variable_name = true,
        },
        -- Formatter & importers (modern stack)
        gofmt = 'gofumpt', -- stricter than gofmt
        goimports = 'gci', -- smarter than goimports
        -- Format on save (set to false if you prefer manual)
        run_in_floaterm = false,
        trouble = false,
        -- Linting via golangci-lint v2
        linter = 'golangci-lint',
        linter_flags = {
          ['golangci-lint'] = { 'run' },
        },
        -- Testing
        test_runner = 'go', -- use built-in `go test`; can swap to 'gotestsum' or 'richgo'
        verbose_tests = true,
        run_in_term = false,
        -- DAP integration
        dap_debug = true,
        dap_debug_keymap = false, -- we use neotest + manual dap keymaps
        dap_debug_gui = true,
        dap_debug_vt = { enabled = true, enabled_commands = true },
        dap_port = 38697,
        dap_timeout = 15,
        dap_retries = 20,
        build_tags = '',
        textobjects = true,
      }

      -- Keymaps for Go-specific commands
      local map = function(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { desc = '[Go] ' .. desc })
      end
      -- Run / test
      map('<leader>gor', '<cmd>GoRun<CR>', 'Run')
      map('<leader>got', '<cmd>GoTest<CR>', 'Test (file)')
      map('<leader>goT', '<cmd>GoTestPkg<CR>', 'Test (package)')
      map('<leader>gof', '<cmd>GoTestFunc<CR>', 'Test (function)')
      map('<leader>goc', '<cmd>GoCoverage -p<CR>', 'Coverage (toggle)')
      -- Code generation
      map('<leader>gie', '<cmd>GoIfErr<CR>', 'if err != nil')
      map('<leader>gfs', '<cmd>GoFillStruct<CR>', 'Fill struct')
      map('<leader>gfk', '<cmd>GoFillSwitch<CR>', 'Fill switch')
      map('<leader>gat', '<cmd>GoAddTag<CR>', 'Add struct tags')
      map('<leader>grt', '<cmd>GoRmTag<CR>', 'Remove struct tags')
      map('<leader>gim', '<cmd>GoImpl<CR>', 'Impl interface')
      map('<leader>gge', '<cmd>GoGenerate<CR>', 'Generate (//go:generate)')
      map('<leader>gmc', '<cmd>GoMockGen<CR>', 'Mock (interface)')
      -- Module / dependencies
      map('<leader>gmt', '<cmd>GoModTidy<CR>', 'go mod tidy')
      map('<leader>gmv', '<cmd>GoModVendor<CR>', 'go mod vendor')
      -- Linting (manual)
      map('<leader>gol', '<cmd>GoLint<CR>', 'golangci-lint run')
      -- Doc lookup at cursor
      map('K', '<cmd>GoDoc<CR>', 'Hover Go doc')
    end,
  },

  -- ────────────────────────────────────────────────────────────
  -- nvim-dap + nvim-dap-go + nvim-dap-ui — Delve debugger
  -- ────────────────────────────────────────────────────────────
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
      'leoluz/nvim-dap-go',
    },
    keys = {
      { '<F5>', function() require('dap').continue() end, desc = 'Debug: Start/Continue' },
      { '<F10>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
      { '<F11>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
      { '<F12>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Breakpoint' },
      { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Cond breakpoint: ')) end, desc = 'Debug: Conditional BP' },
      { '<leader>du', function() require('dapui').toggle() end, desc = 'Debug: Toggle UI' },
      { '<leader>dt', function() require('dap-go').debug_test() end, desc = 'Debug: Go test' },
      { '<leader>dl', function() require('dap-go').debug_last_test() end, desc = 'Debug: Go last test' },
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      dapui.setup()
      require('nvim-dap-virtual-text').setup {
        enabled = true,
        commented = true,
      }
      require('dap-go').setup {
        delve = {
          -- Path to dlv binary; uses PATH by default. Mason installs to ~/.local/share/nvim/mason/bin/dlv
          path = 'dlv',
          initialize_timeout_sec = 20,
        },
      }

      -- Auto-open / close DAP UI on session events
      dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
      dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
      dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

      -- Breakpoint icons
      vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError' })
      vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticWarn' })
    end,
  },

  -- ────────────────────────────────────────────────────────────
  -- neotest + neotest-golang — modern test runner
  -- ────────────────────────────────────────────────────────────
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'fredrikaverpil/neotest-golang',
    },
    keys = {
      { '<leader>nt', function() require('neotest').run.run() end, desc = '[N]eotest [T]est nearest' },
      { '<leader>nf', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = '[N]eotest [F]ile' },
      { '<leader>na', function() require('neotest').run.run(vim.uv.cwd()) end, desc = '[N]eotest [A]ll' },
      { '<leader>ns', function() require('neotest').summary.toggle() end, desc = '[N]eotest [S]ummary' },
      { '<leader>no', function() require('neotest').output.open({ enter = true, auto_close = true }) end, desc = '[N]eotest [O]utput' },
      { '<leader>nO', function() require('neotest').output_panel.toggle() end, desc = '[N]eotest [O]utput panel' },
      { '<leader>nx', function() require('neotest').run.stop() end, desc = '[N]eotest stop' },
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require('neotest-golang') {
            go_test_args = { '-v', '-race', '-count=1' },
            dap_go_enabled = true, -- enables debug-this-test via dap-go
          },
        },
      }
    end,
  },
}
