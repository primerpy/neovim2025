-- Custom code snippets for different purposes

-- Prevent LSP from overwriting treesitter color settings
-- https://github.com/NvChad/NvChad/issues/1907
vim.hl.priorities.semantic_tokens = 95 -- Or any number lower than 100, treesitter's priority level

-- Appearance of diagnostics
vim.diagnostic.config {
  virtual_text = {
    prefix = '●',
    -- Add a custom format function to show error codes
    format = function(diagnostic)
      local code = diagnostic.code and string.format('[%s]', diagnostic.code) or ''
      return string.format('%s %s', code, diagnostic.message)
    end,
  },
  underline = false,
  update_in_insert = true,
  float = {
    source = true,
    border = 'rounded',
    width = 120,
    wrap = true,
    wrap_at = 120,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.INFO] = ' ',
      [vim.diagnostic.severity.HINT] = '󰌵 ',
    },
  },
  -- Make diagnostic background transparent
  on_ready = function()
    vim.cmd 'highlight DiagnosticVirtualText guibg=NONE'
  end,
}

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Set 2-space tabs for Django templates
local django_group = vim.api.nvim_create_augroup('DjangoTemplates', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'htmldjango',
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
  group = django_group,
})

-- Jinja2/DTL filetype detection
vim.filetype.add {
  extension = {
    jinja = 'htmldjango',
    jinja2 = 'htmldjango',
    j2 = 'htmldjango',
  },
  pattern = {
    ['.*%.html%.jinja'] = 'htmldjango',
    ['.*%.html%.jinja2'] = 'htmldjango',
    ['.*%.html%.j2'] = 'htmldjango',
  },
}

-- Auto-detect Jinja2/DTL syntax in .html files
local template_group = vim.api.nvim_create_augroup('TemplateDetection', { clear = true })
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.html',
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false) -- Check first 50 lines
    local content = table.concat(lines, '\n')
    -- Check for Jinja2/DTL patterns: {% %}, {{ }}, {# #}
    if content:match('{%%') or content:match('{{') or content:match('{#') then
      vim.bo.filetype = 'htmldjango'
    end
  end,
  group = template_group,
})

-- LaTeX settings: enable line wrapping and set text width
local latex_group = vim.api.nvim_create_augroup('LaTeXSettings', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'tex', 'latex', 'plaintex' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true -- Wrap at word boundaries
    vim.opt_local.textwidth = 0 -- Disable auto hard-wrap, use visual wrap only
    vim.opt_local.spell = true -- Enable spell checking
    vim.opt_local.spelllang = 'en_us'
  end,
  group = latex_group,
})
