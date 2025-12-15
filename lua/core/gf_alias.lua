-- Transform path aliases for gf (go to file) command
local M = {}

-- Common Vite/React path aliases (ordered by specificity - longer patterns first)
local aliases = {
  { pattern = '@components', path = 'src/components' },
  { pattern = '~img', path = 'src/assets/images' },
  { pattern = '#types', path = 'src/types' },
  { pattern = '@', path = 'src' },
}

function M.transform(fname)
  for _, alias in ipairs(aliases) do
    local pattern = '^' .. alias.pattern:gsub('([^%w])', '%%%1') .. '/'
    if fname:match(pattern) then
      return fname:gsub(pattern, alias.path .. '/')
    end
    -- Also handle exact match without trailing slash (e.g., @components -> src/components/index)
    if fname == alias.pattern then
      return alias.path
    end
  end
  return fname
end

return M
