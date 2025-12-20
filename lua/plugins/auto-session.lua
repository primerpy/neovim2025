return {
  'rmagatti/auto-session',
  lazy = false,
  opts = {
    auto_restore = true,
    auto_save = true,
    auto_restore_last_session = false,
    suppressed_dirs = { '~/', '~/Downloads', '/' },
    -- Close neo-tree before save/restore
    pre_save_cmds = { 'Neotree close' },
    post_restore_cmds = { 'Neotree close' },
  },
  keys = {
    { '<leader>qs', '<cmd>SessionRestore<cr>', desc = 'Restore session for cwd' },
    { '<leader>qS', '<cmd>SessionSave<cr>', desc = 'Save session' },
    { '<leader>qd', '<cmd>SessionDelete<cr>', desc = 'Delete session' },
  },
}
