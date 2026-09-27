 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#19120c',
    base01 = '#251e17',
    base02 = '#302921',
    base03 = '#a08e7d',
    base04 = '#d7c3b0',
    base05 = '#eee0d4',
    base06 = '#eee0d4',
    base07 = '#eee0d4',
    base08 = '#ffb4ab',
    base09 = '#cbd966',
    base0A = '#ebbe8f',
    base0B = '#ffc688',
    base0C = '#c1cf5e',
    base0D = '#ffb868',
    base0E = '#ebbe8f',
    base0F = '#ffddbb',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#eee0d4',          bg = '#19120c' })
  hi('TelescopeBorder',         { fg = '#a08e7d',             bg = '#19120c' })
  hi('TelescopePromptNormal',   { fg = '#eee0d4',          bg = '#19120c' })
  hi('TelescopePromptBorder',   { fg = '#a08e7d',             bg = '#19120c' })
  hi('TelescopePromptPrefix',   { fg = '#ffc688',             bg = '#19120c' })
  hi('TelescopePromptCounter',  { fg = '#d7c3b0',  bg = '#19120c' })
  hi('TelescopePromptTitle',    { fg = '#19120c',             bg = '#ffc688' })
  hi('TelescopePreviewTitle',   { fg = '#19120c',             bg = '#ebbe8f' })
  hi('TelescopeResultsTitle',   { fg = '#19120c',             bg = '#cbd966' })
  hi('TelescopeSelection',      { fg = '#eee0d4',          bg = '#302921' })
  hi('TelescopeSelectionCaret', { fg = '#ffc688',             bg = '#302921' })
  hi('TelescopeMatching',       { fg = '#ffc688',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#eee0d4',          bg = '#19120c' })
  hi('MiniPickBorder',         { fg = '#a08e7d',             bg = '#19120c' })
  hi('MiniPickPrompt',   { fg = '#eee0d4',          bg = '#19120c' })
  hi('MiniPickPromptPrefix',   { fg = '#ffc688',             bg = '#19120c' })
  hi('MiniPickBorderText',    { fg = '#19120c',             bg = '#ffc688' })
  hi('MiniPickMatchCurrent',      { fg = '#eee0d4',          bg = '#302921' })
  hi('MiniPickPromptCaret', { fg = '#ffc688',             bg = '#302921' })
  hi('MiniPickMatchRanges',       { fg = '#ffc688',             bold = true })
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
