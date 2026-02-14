return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      -- Ensure parser install dir is in runtimepath (lazy.nvim may strip it)
      local install_dir = vim.fn.stdpath 'data' .. '/site'
      if not vim.tbl_contains(vim.opt.rtp:get(), install_dir) then
        vim.opt.rtp:prepend(install_dir)
      end

      local parsers = {
        'lua', 'vim', 'vimdoc', 'regex', 'bash',
        'javascript', 'typescript', 'tsx', 'html', 'css',
        'python', 'go', 'rust', 'java',
        'json', 'yaml', 'toml', 'graphql',
        'terraform', 'sql', 'dockerfile', 'make', 'cmake',
        'markdown', 'markdown_inline', 'groovy', 'gitignore', 'htmldjango',
      }

      -- Auto-install missing parsers on startup
      vim.api.nvim_create_autocmd('VimEnter', {
        once = true,
        callback = function()
          local installed = require('nvim-treesitter.config').get_installed()
          local to_install = vim.tbl_filter(function(p)
            return not vim.tbl_contains(installed, p)
          end, parsers)
          if #to_install > 0 then
            vim.cmd('TSInstall ' .. table.concat(to_install, ' '))
          end
        end,
      })
    end,
  }
