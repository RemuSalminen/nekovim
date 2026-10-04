return {
  {
    "ansible-vim",
    for_cat = "ansible",
    auto_enable = true,
    after = function(_)
      require("ansible").setup({})
    end,
  },
  {
    "ansiblels",
    for_cat = "ansible",
    lsp = {
      filetypes = { "ansible", "yaml.ansible" },
    },
  },
}
