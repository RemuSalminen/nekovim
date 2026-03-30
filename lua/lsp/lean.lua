return {
  {
    "lean.nvim",
    for_cat = "lean",
    ft = "lean",
    lazy = false,
    after = function(_)
      require("lean").setup({
        mappings = true
      })
    end,
  },
}
