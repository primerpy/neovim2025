return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  ft = { 'markdown' },
  build = 'cd app && npm install',
  init = function()
    vim.g.mkdp_filetypes = { 'markdown' }
    -- Enable Mermaid support
    vim.g.mkdp_preview_options = {
      mermaid = {},
      katex = {},
    }
    -- Auto-close browser when leaving markdown buffer
    vim.g.mkdp_auto_close = 1
    -- Refresh preview on save or when leaving insert mode
    vim.g.mkdp_refresh_slow = 0
    -- Custom CSS for full-width preview
    vim.g.mkdp_markdown_css = vim.fn.expand('~/.config/nvim/styles/markdown-preview.css')

    -- Set keymap for markdown files
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'markdown',
      callback = function()
        vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', {
          buffer = true,
          desc = 'Toggle Markdown Preview',
        })

        local filter = vim.fn.expand('~/.config/nvim/scripts/mermaid-filter.lua')

        -- Export to PDF with pandoc
        vim.keymap.set('n', '<leader>md', function()
          local file = vim.fn.expand('%:p')
          local output = vim.fn.expand('%:p:r') .. '.pdf'
          local css = vim.fn.expand('~/.config/nvim/styles/markdown-preview.css')
          vim.notify('Exporting to PDF...', vim.log.levels.INFO)
          local cmd = string.format(
            'pandoc "%s" -o "%s" --pdf-engine=wkhtmltopdf --css="%s" --lua-filter="%s" -V margin-top=20mm -V margin-bottom=20mm -V margin-left=15mm -V margin-right=15mm',
            file,
            output,
            css,
            filter
          )
          vim.fn.jobstart(cmd, {
            on_exit = function(_, code)
              if code == 0 then
                vim.notify('Exported to ' .. output, vim.log.levels.INFO)
              else
                vim.notify('PDF export failed', vim.log.levels.ERROR)
              end
            end,
          })
        end, { buffer = true, desc = 'Export to PDF' })

        -- Export to HTML with pandoc
        vim.keymap.set('n', '<leader>mh', function()
          local file = vim.fn.expand('%:p')
          local output = vim.fn.expand('%:p:r') .. '.html'
          local css = vim.fn.expand('~/.config/nvim/styles/markdown-preview.css')
          vim.notify('Exporting to HTML...', vim.log.levels.INFO)
          local cmd = string.format(
            'pandoc "%s" -o "%s" --standalone --self-contained --css="%s" --lua-filter="%s" --metadata title="%s"',
            file,
            output,
            css,
            filter,
            vim.fn.expand('%:t:r')
          )
          vim.fn.jobstart(cmd, {
            on_exit = function(_, code)
              if code == 0 then
                vim.notify('Exported to ' .. output, vim.log.levels.INFO)
              else
                vim.notify('HTML export failed', vim.log.levels.ERROR)
              end
            end,
          })
        end, { buffer = true, desc = 'Export to HTML' })
      end,
    })
  end,
}
