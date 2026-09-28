 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#121317',
    base01 = '#1f1f23',
    base02 = '#292a2e',
    base03 = '#8f909b',
    base04 = '#c5c6d1',
    base05 = '#e3e2e7',
    base06 = '#e3e2e7',
    base07 = '#e3e2e7',
    base08 = '#ffb4ab',
    base09 = '#efb3ef',
    base0A = '#bfc6e2',
    base0B = '#b3c5ff',
    base0C = '#efb3ef',
    base0D = '#b3c5ff',
    base0E = '#bfc6e2',
    base0F = '#dbe1ff',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e3e2e7',          bg = '#121317' })
  hi('TelescopeBorder',         { fg = '#8f909b',             bg = '#121317' })
  hi('TelescopePromptNormal',   { fg = '#e3e2e7',          bg = '#121317' })
  hi('TelescopePromptBorder',   { fg = '#8f909b',             bg = '#121317' })
  hi('TelescopePromptPrefix',   { fg = '#b3c5ff',             bg = '#121317' })
  hi('TelescopePromptCounter',  { fg = '#c5c6d1',  bg = '#121317' })
  hi('TelescopePromptTitle',    { fg = '#121317',             bg = '#b3c5ff' })
  hi('TelescopePreviewTitle',   { fg = '#121317',             bg = '#bfc6e2' })
  hi('TelescopeResultsTitle',   { fg = '#121317',             bg = '#efb3ef' })
  hi('TelescopeSelection',      { fg = '#e3e2e7',          bg = '#292a2e' })
  hi('TelescopeSelectionCaret', { fg = '#b3c5ff',             bg = '#292a2e' })
  hi('TelescopeMatching',       { fg = '#b3c5ff',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e3e2e7',          bg = '#121317' })
  hi('MiniPickBorder',         { fg = '#8f909b',             bg = '#121317' })
  hi('MiniPickPrompt',   { fg = '#e3e2e7',          bg = '#121317' })
  hi('MiniPickPromptPrefix',   { fg = '#b3c5ff',             bg = '#121317' })
  hi('MiniPickBorderText',    { fg = '#121317',             bg = '#b3c5ff' })
  hi('MiniPickMatchCurrent',      { fg = '#e3e2e7',          bg = '#292a2e' })
  hi('MiniPickPromptCaret', { fg = '#b3c5ff',             bg = '#292a2e' })
  hi('MiniPickMatchRanges',       { fg = '#b3c5ff',             bold = true })
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
