return {
  {
    "which-key.nvim",
    after = function (_)
      require("which-key").setup({
        icons = { separator = '󰁔 ' },
        spec = {
          mode = { 'n', 'v' },
          { '<leader>b', group = '+buffer' },
          { '<leader>g', group = '+git' },
          { '<leader>x', group = '+diagnostics/quickfix' },
        },
      })
    end
  }
}
