-- Pandoc Lua filter to render Mermaid diagrams using mmdc
local system = require 'pandoc.system'

local function render_mermaid(code, format)
  local tmp_dir = system.get_working_directory()
  local input_file = os.tmpname() .. '.mmd'
  local output_file = os.tmpname() .. '.png'

  -- Write mermaid code to temp file
  local f = io.open(input_file, 'w')
  f:write(code)
  f:close()

  -- Run mmdc to generate image
  local cmd = string.format(
    'mmdc -i "%s" -o "%s" -b transparent -t neutral 2>/dev/null',
    input_file,
    output_file
  )
  os.execute(cmd)

  -- Read the generated image
  local img_file = io.open(output_file, 'rb')
  if img_file then
    local img_data = img_file:read('*all')
    img_file:close()

    -- Clean up temp files
    os.remove(input_file)
    os.remove(output_file)

    if #img_data > 0 then
      -- Return image element
      local mime = 'image/png'
      local img = pandoc.Image({}, output_file)
      -- For HTML output, embed as base64
      if format == 'html' or format == 'html5' then
        local b64 = pandoc.pipe('base64', { '-w', '0' }, img_data)
        local src = 'data:' .. mime .. ';base64,' .. b64
        return pandoc.Para({ pandoc.Image({}, src) })
      else
        -- For PDF, save image and reference it
        local final_img = os.tmpname() .. '.png'
        local out = io.open(final_img, 'wb')
        out:write(img_data)
        out:close()
        return pandoc.Para({ pandoc.Image({}, final_img) })
      end
    end
  end

  -- Clean up on failure
  os.remove(input_file)
  os.remove(output_file)

  -- Return original code block if rendering failed
  return nil
end

function CodeBlock(block)
  if block.classes[1] == 'mermaid' then
    local result = render_mermaid(block.text, FORMAT)
    if result then
      return result
    end
  end
  return block
end
