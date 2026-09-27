return {
  {
    "render-markdown.nvim",
    for_cat = "markdown",
    ft = "markdown",
    after = function(_)
      require("render-markdown").setup({})
    end,
  },
}
