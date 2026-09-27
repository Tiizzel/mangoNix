 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#1a110e',
    base01 = '#271d1a',
    base02 = '#322824',
    base03 = '#a48c83',
    base04 = '#dcc1b7',
    base05 = '#f1dfd9',
    base06 = '#f1dfd9',
    base07 = '#f1dfd9',
    base08 = '#ffb4ab',
    base09 = '#d0cb50',
    base0A = '#f6b8a1',
    base0B = '#ffb599',
    base0C = '#d0cb50',
    base0D = '#ffb599',
    base0E = '#f6b8a1',
    base0F = '#ffdbce',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#f1dfd9',          bg = '#1a110e' })
  hi('TelescopeBorder',         { fg = '#a48c83',             bg = '#1a110e' })
  hi('TelescopePromptNormal',   { fg = '#f1dfd9',          bg = '#1a110e' })
  hi('TelescopePromptBorder',   { fg = '#a48c83',             bg = '#1a110e' })
  hi('TelescopePromptPrefix',   { fg = '#ffb599',             bg = '#1a110e' })
  hi('TelescopePromptCounter',  { fg = '#dcc1b7',  bg = '#1a110e' })
  hi('TelescopePromptTitle',    { fg = '#1a110e',             bg = '#ffb599' })
  hi('TelescopePreviewTitle',   { fg = '#1a110e',             bg = '#f6b8a1' })
  hi('TelescopeResultsTitle',   { fg = '#1a110e',             bg = '#d0cb50' })
  hi('TelescopeSelection',      { fg = '#f1dfd9',          bg = '#322824' })
  hi('TelescopeSelectionCaret', { fg = '#ffb599',             bg = '#322824' })
  hi('TelescopeMatching',       { fg = '#ffb599',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#f1dfd9',          bg = '#1a110e' })
  hi('MiniPickBorder',         { fg = '#a48c83',             bg = '#1a110e' })
  hi('MiniPickPrompt',   { fg = '#f1dfd9',          bg = '#1a110e' })
  hi('MiniPickPromptPrefix',   { fg = '#ffb599',             bg = '#1a110e' })
  hi('MiniPickBorderText',    { fg = '#1a110e',             bg = '#ffb599' })
  hi('MiniPickMatchCurrent',      { fg = '#f1dfd9',          bg = '#322824' })
  hi('MiniPickPromptCaret', { fg = '#ffb599',             bg = '#322824' })
  hi('MiniPickMatchRanges',       { fg = '#ffb599',             bold = true })
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
