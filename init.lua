-- Ensure NVM node is in PATH for LSP servers (auto-detects latest version)
local nvm_dir = vim.fn.expand('$HOME/.nvm/versions/node')
local node_dirs = vim.fn.glob(nvm_dir .. '/v*', false, true)
if #node_dirs > 0 then
  -- Sort by semantic version to get the latest
  table.sort(node_dirs, function(a, b)
    local function parse_version(path)
      local ver = path:match('/v(%d+)%.(%d+)%.(%d+)')
      if ver then
        local major, minor, patch = path:match('/v(%d+)%.(%d+)%.(%d+)')
        return tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
      end
      return 0
    end
    return parse_version(a) < parse_version(b)
  end)
  local node_path = node_dirs[#node_dirs] .. '/bin'
  vim.env.PATH = node_path .. ':' .. vim.env.PATH
end

require 'core.options'
require 'core.keymaps'

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins
require('lazy').setup {
  require 'plugins.alpha',
  require 'plugins.neotree',
  require 'plugins.colortheme',
  require 'plugins.bufferline',
  require 'plugins.lualine',
  require 'plugins.treesitter',
  require 'plugins.telescope',
  require 'plugins.lsp',
  require 'plugins.lazydev',
  require 'plugins.autocompletion',
  require 'plugins.none-ls',
  require 'plugins.gitsigns',
  require 'plugins.claudecode',
  require 'plugins.comment',
  require 'plugins.indent-blankline',
  require 'plugins.misc',
}
