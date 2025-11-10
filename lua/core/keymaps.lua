vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- save file without auto-formatting
vim.keymap.set('n', '<leader>wn', '<cmd>noautocmd w <CR>', { noremap = true, silent = true, desc = 'Write file without formatting' })

-- Resize with arrows
vim.keymap.set('n', '<Up>', ':resize -2<CR>', { noremap = true, silent = true, desc = 'Decrease window height' })
vim.keymap.set('n', '<Down>', ':resize +2<CR>', { noremap = true, silent = true, desc = 'Increase window height' })
vim.keymap.set('n', '<Left>', ':vertical :resize +2<CR>', { noremap = true, silent = true, desc = 'Increase window width' })
vim.keymap.set('n', '<Right>', ':vertical :resize -2<CR>', { noremap = true, silent = true, desc = 'Decrease window width' })

-- Buffer
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { noremap = true, silent = true, desc = 'Next buffer' })
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', { noremap = true, silent = true, desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bx', ':Bdelete!<CR>', { noremap = true, silent = true, desc = 'Close buffer' })
vim.keymap.set('n', '<leader>ba', ':%bd|e#|bd#<CR>', { noremap = true, silent = true, desc = 'Close all buffers except current' })
vim.keymap.set('n', '<leader>bo', '<cmd> enew<CR>', { noremap = true, silent = true, desc = 'New buffer' })

-- Window management
vim.keymap.set('n', '<leader>v', '<C-w>v', { noremap = true, silent = true, desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>h', '<C-w>s', { noremap = true, silent = true, desc = 'Split window horizontally' })
vim.keymap.set('n', '<leader>se', '<C-w>=', { noremap = true, silent = true, desc = 'Make splits equal size' })
vim.keymap.set('n', '<leader>xs', ':close<CR>', { noremap = true, silent = true, desc = 'Close current split' })

-- Navigate between splits
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', { noremap = true, silent = true, desc = 'Move to upper split' })
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', { noremap = true, silent = true, desc = 'Move to lower split' })
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', { noremap = true, silent = true, desc = 'Move to left split' })
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', { noremap = true, silent = true, desc = 'Move to right split' })

-- Tabs
vim.keymap.set('n', '<leader>to', ':tabnew<CR>', { noremap = true, silent = true, desc = 'Open new tab' })
vim.keymap.set('n', '<leader>tx', ':tabclose<CR>', { noremap = true, silent = true, desc = 'Close current tab' })
vim.keymap.set('n', '<leader>ta', ':tabonly<CR>', { noremap = true, silent = true, desc = 'Close all tabs except current' })
vim.keymap.set('n', '<leader>tn', ':tabn<CR>', { noremap = true, silent = true, desc = 'Next tab' })
vim.keymap.set('n', '<leader>tp', ':tabp<CR>', { noremap = true, silent = true, desc = 'Previous tab' })

-- Toggle line wrapping
vim.keymap.set('n', '<leader>lw', '<cmd>set wrap!<CR>', { noremap = true, silent = true, desc = 'Toggle line wrapping' })

-- Folding
vim.keymap.set('n', '<leader>za', 'za', { noremap = true, silent = true, desc = 'Toggle fold at cursor' })
vim.keymap.set('n', '<leader>zM', 'zM', { noremap = true, silent = true, desc = 'Close all folds' })
vim.keymap.set('n', '<leader>zR', 'zR', { noremap = true, silent = true, desc = 'Open all folds' })
vim.keymap.set('n', '<leader>zo', 'zo', { noremap = true, silent = true, desc = 'Open fold at cursor' })
vim.keymap.set('n', '<leader>zc', 'zc', { noremap = true, silent = true, desc = 'Close fold at cursor' })
vim.keymap.set('n', 'zj', 'zj', { noremap = true, silent = true, desc = 'Move to next fold' })
vim.keymap.set('n', 'zk', 'zk', { noremap = true, silent = true, desc = 'Move to previous fold' })

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', { noremap = true, silent = true, desc = 'Indent left and reselect' })
vim.keymap.set('v', '>', '>gv', { noremap = true, silent = true, desc = 'Indent right and reselect' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous diagnostic message' })

vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next diagnostic message' })

vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Claude
vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeCode<CR>', { desc = 'Toggle Claude Code' })
