-- Easily comment visual regions/lines
return {
  'numToStr/Comment.nvim',
  opts = {},
  config = function()
    vim.keymap.set('n', '<C-_>', require('Comment.api').toggle.linewise.current, { noremap = true, silent = true, desc = 'Toggle comment line' })
    vim.keymap.set('n', '<C-c>', require('Comment.api').toggle.linewise.current, { noremap = true, silent = true, desc = 'Toggle comment line' })
    vim.keymap.set('n', '<C-/>', require('Comment.api').toggle.linewise.current, { noremap = true, silent = true, desc = 'Toggle comment line' })
    vim.keymap.set('v', '<C-_>', "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>", { noremap = true, silent = true, desc = 'Toggle comment selection' })
    vim.keymap.set('v', '<C-c>', "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>", { noremap = true, silent = true, desc = 'Toggle comment selection' })
    vim.keymap.set('v', '<C-/>', "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>", { noremap = true, silent = true, desc = 'Toggle comment selection' })
  end,
}
