return {
  {
    "lean.nvim",
    for_cat = "lean",
    ft = "lean",
    after = function(_)
      require("lean").setup({
        mappings = true
      })
    end,
  },
}
