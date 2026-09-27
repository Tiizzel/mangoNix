 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#151217',
    base01 = '#221e24',
    base02 = '#2c292e',
    base03 = '#968e98',
    base04 = '#cdc4ce',
    base05 = '#e8e0e8',
    base06 = '#e8e0e8',
    base07 = '#e8e0e8',
    base08 = '#ffb4ab',
    base09 = '#f3b7bd',
    base0A = '#d1c1d9',
    base0B = '#dbb9f9',
    base0C = '#f3b7bd',
    base0D = '#dbb9f9',
    base0E = '#d1c1d9',
    base0F = '#edddf6',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e8e0e8',          bg = '#151217' })
  hi('TelescopeBorder',         { fg = '#968e98',             bg = '#151217' })
  hi('TelescopePromptNormal',   { fg = '#e8e0e8',          bg = '#151217' })
  hi('TelescopePromptBorder',   { fg = '#968e98',             bg = '#151217' })
  hi('TelescopePromptPrefix',   { fg = '#dbb9f9',             bg = '#151217' })
  hi('TelescopePromptCounter',  { fg = '#cdc4ce',  bg = '#151217' })
  hi('TelescopePromptTitle',    { fg = '#151217',             bg = '#dbb9f9' })
  hi('TelescopePreviewTitle',   { fg = '#151217',             bg = '#d1c1d9' })
  hi('TelescopeResultsTitle',   { fg = '#151217',             bg = '#f3b7bd' })
  hi('TelescopeSelection',      { fg = '#e8e0e8',          bg = '#2c292e' })
  hi('TelescopeSelectionCaret', { fg = '#dbb9f9',             bg = '#2c292e' })
  hi('TelescopeMatching',       { fg = '#dbb9f9',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e8e0e8',          bg = '#151217' })
  hi('MiniPickBorder',         { fg = '#968e98',             bg = '#151217' })
  hi('MiniPickPrompt',   { fg = '#e8e0e8',          bg = '#151217' })
  hi('MiniPickPromptPrefix',   { fg = '#dbb9f9',             bg = '#151217' })
  hi('MiniPickBorderText',    { fg = '#151217',             bg = '#dbb9f9' })
  hi('MiniPickMatchCurrent',      { fg = '#e8e0e8',          bg = '#2c292e' })
  hi('MiniPickPromptCaret', { fg = '#dbb9f9',             bg = '#2c292e' })
  hi('MiniPickMatchRanges',       { fg = '#dbb9f9',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
