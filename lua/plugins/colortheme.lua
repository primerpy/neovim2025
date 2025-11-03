-- 🎨 Gruvbox theme
return {
  "ellisonleao/gruvbox.nvim",
  lazy = false,       -- load immediately
  priority = 1000,    -- load before other plugins
  config = function()
    local gruvbox = require("gruvbox")

    -- initial setup
    local bg_transparent = false

    local function apply_gruvbox()
      gruvbox.setup({
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        inverse = true, -- invert background for search, diffs, statuslines and errors
        contrast = "",  -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = bg_transparent,
      })
      vim.cmd("colorscheme gruvbox")
    end

    -- toggle function
    local function toggle_transparency()
      bg_transparent = not bg_transparent
      apply_gruvbox()
      if bg_transparent then
        print("🌿 Gruvbox: Transparency ON")
      else
        print("🌑 Gruvbox: Transparency OFF")
      end
    end

    -- keymap
    vim.keymap.set("n", "<leader>bg", toggle_transparency, { noremap = true, silent = true, desc = "Toggle background transparency" })

    -- apply colorscheme initially
    apply_gruvbox()
  end,
}

