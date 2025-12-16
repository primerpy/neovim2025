return {
  'nvim-lualine/lualine.nvim',
  config = function()
    -- Check if using a non-nerd font (set NVIM_FONT=MonoLisa in your shell rc)
    local is_monolisa = vim.env.NVIM_FONT == 'MonoLisa'

    local mode = {
      'mode',
      fmt = function(str)
        return ' ' .. str
        -- return ' ' .. str:sub(1, 1) -- displays only the first character of the mode
      end,
    }

    local filename = {
      'filename',
      file_status = true, -- displays file status (readonly status, modified status)
      path = 0, -- 0 = just filename, 1 = relative path, 2 = absolute path
    }

    local hide_in_width = function()
      return vim.fn.winwidth(0) > 100
    end

    local diagnostics = {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      sections = { 'error', 'warn' },
      symbols = is_monolisa and { error = 'E:', warn = 'W:', info = 'I:', hint = 'H:' }
        or { error = '\u{f057} ', warn = '\u{f071} ', info = '\u{f05a} ', hint = '\u{f059} ' },
      colored = false,
      update_in_insert = false,
      always_visible = false,
      cond = hide_in_width,
    }

    local diff = {
      'diff',
      colored = false,
      symbols = is_monolisa and { added = '+', modified = '~', removed = '-' }
        or { added = '\u{f457} ', modified = '\u{f459} ', removed = '\u{f458} ' },
      cond = hide_in_width,
    }

    -- Separators based on font
    local section_seps = is_monolisa and { left = '', right = '' } or { left = '\u{e0b0}', right = '\u{e0b2}' }
    local component_seps = is_monolisa and { left = '|', right = '|' } or { left = '\u{e0b1}', right = '\u{e0b3}' }

    require('lualine').setup {
      options = {
        icons_enabled = not is_monolisa,
        theme = 'gruvbox', -- Set theme based on environment variable
        -- Some useful glyphs:
        -- https://www.nerdfonts.com/cheat-sheet
        section_separators = section_seps,
        component_separators = component_seps,
        disabled_filetypes = { 'alpha', 'neo-tree' },
        always_divide_middle = true,
      },
      sections = {
        lualine_a = { mode },
        lualine_b = { 'branch' },
        lualine_c = { filename },
        lualine_x = { diagnostics, diff, { 'encoding', cond = hide_in_width }, { 'filetype', cond = hide_in_width } },
        lualine_y = { 'location' },
        lualine_z = { 'progress' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { { 'location', padding = 0 } },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = { 'fugitive' },
    }
  end,
}
