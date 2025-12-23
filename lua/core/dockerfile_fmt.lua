-- Dockerfile formatter with best practices
local M = {}

-- Dockerfile instructions that should be uppercase
local instructions = {
  'FROM', 'RUN', 'CMD', 'LABEL', 'MAINTAINER', 'EXPOSE', 'ENV', 'ADD', 'COPY',
  'ENTRYPOINT', 'VOLUME', 'USER', 'WORKDIR', 'ARG', 'ONBUILD', 'STOPSIGNAL',
  'HEALTHCHECK', 'SHELL',
}

-- Format JSON arrays: ["a","b"] → ["a", "b"]
local function format_json_array(str)
  -- Add space after commas in arrays
  str = str:gsub('%[%s*', '[')
  str = str:gsub('%s*%]', ']')
  str = str:gsub(',%s*', ', ')
  str = str:gsub('%[([^%]]+)%]', function(content)
    -- Trim spaces around elements
    local elements = {}
    for elem in content:gmatch('[^,]+') do
      elem = elem:match('^%s*(.-)%s*$') -- trim
      table.insert(elements, elem)
    end
    return '[' .. table.concat(elements, ', ') .. ']'
  end)
  return str
end

-- Format flags: --mount=type=cache,target=/root/.cache
local function format_flags(str)
  -- Ensure space before flags
  str = str:gsub('([^%s])%-%-', '%1 --')
  -- No space around = in flags
  str = str:gsub('%-%-(%w+)%s*=%s*', '--%1=')
  return str
end

-- General formatting: spaces after commas, colons, etc.
local function format_general(str)
  -- Space after comma (but not in flag values like --mount=type=cache,target=...)
  if not str:match('%-%-[%w]+=') then
    str = str:gsub(',%s*', ', ')
  end

  -- Space after colon in port mappings, user:group, etc. (but not in URLs)
  -- Only for patterns like 8080:80 or user:group, not http://
  str = str:gsub('([%d]+):%s*([%d]+)', '%1:%2') -- ports: no space
  str = str:gsub('([%w_-]+):%s*([%w_-]+)%s', '%1:%2 ') -- user:group: no space

  -- Space around && and ||
  str = str:gsub('%s*&&%s*', ' && ')
  str = str:gsub('%s*||%s*', ' || ')

  -- Space around | (pipe)
  str = str:gsub('%s*|%s*', ' | ')

  -- Space after ; (but keep it tight)
  str = str:gsub(';%s*', '; ')

  -- No multiple spaces (except leading indentation)
  local leading = str:match('^(%s*)')
  local rest = str:gsub('^%s*', '')
  rest = rest:gsub('%s+', ' ')
  str = leading .. rest

  return str
end

-- Format LABEL instruction (key=value pairs)
local function format_label(str)
  -- LABEL key="value" key2="value2"
  str = str:gsub('"%s+', '" ')
  str = str:gsub('%s*=%s*', '=')
  return str
end

-- Format EXPOSE instruction
local function format_expose(str)
  -- EXPOSE 80 443 8080
  str = str:gsub('EXPOSE%s+', 'EXPOSE ')
  str = str:gsub('%s+', ' ')
  return str
end

function M.format()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local formatted = {}
  local in_continuation = false
  local prev_was_empty = false
  local prev_instruction = nil

  for _, line in ipairs(lines) do
    local formatted_line = line
    local current_instruction = nil

    -- Detect current instruction
    for _, instr in ipairs(instructions) do
      if line:upper():match('^%s*' .. instr .. '[%s%[]') or line:upper():match('^%s*' .. instr .. '$') then
        current_instruction = instr
        break
      end
    end

    -- Skip empty lines (but preserve one)
    if line:match('^%s*$') then
      if not prev_was_empty then
        table.insert(formatted, '')
        prev_was_empty = true
      end
      in_continuation = false
      goto continue
    end
    prev_was_empty = false

    -- Handle comments
    if line:match('^%s*#') then
      -- Ensure comment has space after #
      formatted_line = line:gsub('^(%s*)#([^%s#])', '%1# %2')
      table.insert(formatted, formatted_line)
      in_continuation = false
      goto continue
    end

    -- Add blank line before major sections (FROM, except first)
    if current_instruction == 'FROM' and #formatted > 0 and formatted[#formatted] ~= '' then
      table.insert(formatted, '')
    end

    -- Handle continuation lines
    if in_continuation then
      formatted_line = line:gsub('^%s*', '    ')
    else
      -- Uppercase instructions and remove leading whitespace
      for _, instr in ipairs(instructions) do
        local lower_pattern = '^%s*' .. instr:lower() .. '([%s%[])'
        local mixed_pattern = '^%s*' .. instr .. '([%s%[])'
        if line:lower():match(lower_pattern) then
          formatted_line = line:gsub('^%s*%w+', instr)
          break
        elseif line:match(mixed_pattern) then
          formatted_line = line:gsub('^%s*%w+', instr)
          break
        end
      end
    end

    -- Check if line ends with continuation
    in_continuation = line:match('\\%s*$') ~= nil

    -- Format JSON arrays (CMD, ENTRYPOINT, etc.)
    if formatted_line:match('%[.*%]') then
      formatted_line = format_json_array(formatted_line)
    end

    -- Format flags
    if formatted_line:match('%-%-') then
      formatted_line = format_flags(formatted_line)
    end

    -- Normalize spaces around = in ENV and ARG (no spaces)
    if formatted_line:match('^ENV%s') or formatted_line:match('^ARG%s') then
      formatted_line = formatted_line:gsub('%s*=%s*', '=')
    end

    -- Ensure single space after instruction (but not before [)
    for _, instr in ipairs(instructions) do
      -- Handle instruction followed by space
      formatted_line = formatted_line:gsub('^(' .. instr .. ')%s%s+', '%1 ')
      -- Handle instruction followed by [ (no space needed for JSON syntax)
    end

    -- COPY/ADD: ensure proper spacing
    if formatted_line:match('^COPY') or formatted_line:match('^ADD') then
      -- Format --from=, --chown=, --chmod= flags
      formatted_line = formatted_line:gsub('%s+%-%-', ' --')
      formatted_line = formatted_line:gsub('%-%-(%w+)%s*=%s*', '--%1=')
    end

    -- LABEL: format key=value pairs
    if formatted_line:match('^LABEL') then
      formatted_line = format_label(formatted_line)
    end

    -- EXPOSE: clean up port list
    if formatted_line:match('^EXPOSE') then
      formatted_line = format_expose(formatted_line)
    end

    -- Apply general formatting (spaces after commas, around operators, etc.)
    formatted_line = format_general(formatted_line)

    table.insert(formatted, formatted_line)
    prev_instruction = current_instruction
    ::continue::
  end

  -- Remove trailing empty lines
  while #formatted > 0 and formatted[#formatted] == '' do
    table.remove(formatted)
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted)
  vim.notify('Dockerfile formatted', vim.log.levels.INFO)
end

return M
