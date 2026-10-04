 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#17130e',
    base01 = '#231f19',
    base02 = '#2e2923',
    base03 = '#9b8f7f',
    base04 = '#d3c4b3',
    base05 = '#ebe1d8',
    base06 = '#ebe1d8',
    base07 = '#ebe1d8',
    base08 = '#ffb4ab',
    base09 = '#bfce80',
    base0A = '#dec29d',
    base0B = '#f1be6f',
    base0C = '#bfce80',
    base0D = '#f1be6f',
    base0E = '#dec29d',
    base0F = '#fbdeb7',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#ebe1d8',          bg = '#17130e' })
  hi('TelescopeBorder',         { fg = '#9b8f7f',             bg = '#17130e' })
  hi('TelescopePromptNormal',   { fg = '#ebe1d8',          bg = '#17130e' })
  hi('TelescopePromptBorder',   { fg = '#9b8f7f',             bg = '#17130e' })
  hi('TelescopePromptPrefix',   { fg = '#f1be6f',             bg = '#17130e' })
  hi('TelescopePromptCounter',  { fg = '#d3c4b3',  bg = '#17130e' })
  hi('TelescopePromptTitle',    { fg = '#17130e',             bg = '#f1be6f' })
  hi('TelescopePreviewTitle',   { fg = '#17130e',             bg = '#dec29d' })
  hi('TelescopeResultsTitle',   { fg = '#17130e',             bg = '#bfce80' })
  hi('TelescopeSelection',      { fg = '#ebe1d8',          bg = '#2e2923' })
  hi('TelescopeSelectionCaret', { fg = '#f1be6f',             bg = '#2e2923' })
  hi('TelescopeMatching',       { fg = '#f1be6f',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#ebe1d8',          bg = '#17130e' })
  hi('MiniPickBorder',         { fg = '#9b8f7f',             bg = '#17130e' })
  hi('MiniPickPrompt',   { fg = '#ebe1d8',          bg = '#17130e' })
  hi('MiniPickPromptPrefix',   { fg = '#f1be6f',             bg = '#17130e' })
  hi('MiniPickBorderText',    { fg = '#17130e',             bg = '#f1be6f' })
  hi('MiniPickMatchCurrent',      { fg = '#ebe1d8',          bg = '#2e2923' })
  hi('MiniPickPromptCaret', { fg = '#f1be6f',             bg = '#2e2923' })
  hi('MiniPickMatchRanges',       { fg = '#f1be6f',             bold = true })
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
