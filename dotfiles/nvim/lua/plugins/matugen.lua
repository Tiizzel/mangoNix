return {
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, matugen = pcall(require, "matugen")
      if ok then
        matugen.setup()
      end
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        local ok, matugen = pcall(require, "matugen")
        if ok then
          matugen.setup()
        else
          vim.cmd.colorscheme("tokyonight")
        end
      end,
    },
  },
}
