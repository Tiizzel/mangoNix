 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#121414',
    base01 = '#1e2020',
    base02 = '#292a2a',
    base03 = '#8b9293',
    base04 = '#c1c8c9',
    base05 = '#e3e2e2',
    base06 = '#e3e2e2',
    base07 = '#e3e2e2',
    base08 = '#ffb4ab',
    base09 = '#d0c1dd',
    base0A = '#bdc9cb',
    base0B = '#adccd3',
    base0C = '#d0c1dd',
    base0D = '#adccd3',
    base0E = '#bdc9cb',
    base0F = '#d9e5e7',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e3e2e2',          bg = '#121414' })
  hi('TelescopeBorder',         { fg = '#8b9293',             bg = '#121414' })
  hi('TelescopePromptNormal',   { fg = '#e3e2e2',          bg = '#121414' })
  hi('TelescopePromptBorder',   { fg = '#8b9293',             bg = '#121414' })
  hi('TelescopePromptPrefix',   { fg = '#adccd3',             bg = '#121414' })
  hi('TelescopePromptCounter',  { fg = '#c1c8c9',  bg = '#121414' })
  hi('TelescopePromptTitle',    { fg = '#121414',             bg = '#adccd3' })
  hi('TelescopePreviewTitle',   { fg = '#121414',             bg = '#bdc9cb' })
  hi('TelescopeResultsTitle',   { fg = '#121414',             bg = '#d0c1dd' })
  hi('TelescopeSelection',      { fg = '#e3e2e2',          bg = '#292a2a' })
  hi('TelescopeSelectionCaret', { fg = '#adccd3',             bg = '#292a2a' })
  hi('TelescopeMatching',       { fg = '#adccd3',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e3e2e2',          bg = '#121414' })
  hi('MiniPickBorder',         { fg = '#8b9293',             bg = '#121414' })
  hi('MiniPickPrompt',   { fg = '#e3e2e2',          bg = '#121414' })
  hi('MiniPickPromptPrefix',   { fg = '#adccd3',             bg = '#121414' })
  hi('MiniPickBorderText',    { fg = '#121414',             bg = '#adccd3' })
  hi('MiniPickMatchCurrent',      { fg = '#e3e2e2',          bg = '#292a2a' })
  hi('MiniPickPromptCaret', { fg = '#adccd3',             bg = '#292a2a' })
  hi('MiniPickMatchRanges',       { fg = '#adccd3',             bold = true })
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
