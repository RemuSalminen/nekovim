return {
  {
    "neoscroll.nvim",
    lazy = false,
    after = function (_)
      require("neoscroll").setup({})
    end
  }
}
