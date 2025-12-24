return {
  'rmagatti/auto-session',
  lazy = false,
  init = function()
    -- Clean up [No Name] buffers after startup
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        vim.defer_fn(function()
          for _, buf in ipairs(vim.fn.getbufinfo { buflisted = 1 }) do
            if buf.name == '' and buf.loaded and #buf.windows == 0 then
              pcall(vim.api.nvim_buf_delete, buf.bufnr, { force = true })
            end
          end
        end, 100)
      end,
    })
  end,
  opts = {
    auto_restore = true,
    auto_save = true,
    auto_restore_last_session = false,
    suppressed_dirs = { '~/', '~/Downloads', '/' },
    -- Close neo-tree before save to avoid saving its state
    pre_save_cmds = { 'Neotree close' },
    -- After restore: close neo-tree and focus last real file buffer
    post_restore_cmds = {
      function()
        vim.cmd 'Neotree close'
        -- Focus the last real file buffer
        vim.defer_fn(function()
          local buffers = vim.fn.getbufinfo { buflisted = 1 }
          for i = #buffers, 1, -1 do
            local buf = buffers[i]
            if buf.name ~= '' then
              vim.cmd('buffer ' .. buf.bufnr)
              return
            end
          end
        end, 10)
      end,
    },
    -- When no session exists, open neo-tree
    no_restore_cmds = {
      function()
        vim.cmd 'Neotree show'
      end,
    },
  },
  keys = {
    { '<leader>qs', '<cmd>SessionRestore<cr>', desc = 'Restore session for cwd' },
    { '<leader>qS', '<cmd>SessionSave<cr>', desc = 'Save session' },
    { '<leader>qd', '<cmd>SessionDelete<cr>', desc = 'Delete session' },
  },
}
