return {
  {
    "trigger_colorscheme",
    event = "VimEnter",
    load = function (_name)
      vim.schedule(function ()
        vim.cmd.colorscheme(nixInfo("onedark_dark", "settings", "colorscheme"))
        ---- To tweak settings related to the colorscheme simultaneously
        --vim.schedule(function ()
        --  vim.cmd([[hi LineNr guifg=#bb9af7]])
        --end)
      end)
    end
  },
  {
    "neopywal",
    auto_enable = true,
    colorscheme = { "neopywal", "neopywal-dark", "neopywal-light" },
    after = function(_)
      require("neopywal").setup({})
    end,
  },
  {
    "onedarkpro.nvim",
    auto_enable = true,
    colorscheme = { "onedark", "onelight", "onedark_dark", "onedark_vivid" },
  },
}
