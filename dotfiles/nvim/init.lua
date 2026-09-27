-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

local ok, matugen = pcall(require, 'matugen')
if ok then matugen.setup() end
