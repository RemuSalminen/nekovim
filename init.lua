---- Setup ----
---- The Setup section is licensed under the MIT from nix-wrapper-modules
--Copyright (c) 2025 the contributors

--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

vim.loader.enable()
do
  local ok
  ok, _G.nixInfo = pcall(require, vim.g.nix_info_plugin_name)
  if not ok then
    package.loaded[vim.g.nix_info_plugin_name] = setmetatable({}, {
      __call = function (_, default) return default end
    })
    _G.nixInfo = require(vim.g.nix_info_plugin_name)

    -- TODO: On Non-Nix, vim.pack.add
  end
  nixInfo.isNix = vim.g.nix_info_plugin_name ~= nil
  ---@module 'lzextras'
  ---@type lzextras | lze
  nixInfo.lze = setmetatable(require('lze'), getmetatable(require('lzextras')))
  function nixInfo.get_nix_plugin_path(name)
    return nixInfo(nil, "plugins", "lazy", name) or nixInfo(nil, "plugins", "start", name)
  end
end
nixInfo.lze.register_handlers {
  {
    spec_field = "auto_enable",
    set_lazy = false,
    modify = function(plugin)
      if vim.g.nix_info_plugin_name then
        local auto_enable = plugin.auto_enable
        if type(auto_enable) == "table" then
          for _, name in pairs(plugin.auto_enable) do
            if not nixInfo.get_nix_plugin_path(name) then
              plugin.enable = false
              break
            end
          end
      elseif type(auto_enable) == "string" then
        if not nixInfo.get_nix_plugin_path(auto_enable) then
          plugin.enable = false
        end
      elseif type(auto_enable) == "boolean" then
        if not nixInfo.get_nix_plugin_path(plugin.name) then
          plugin.enable = false
        end
      end
    end
    return plugin
  end,
  },
  {
    -- Use Categories from Module
    -- for_cat = "name" to specify a plugin to be used for a given module
    spec_field = "for_cat",
    set_lazy = false,
    modify = function(plugin)
      if vim.g.nix_info_plugin_name then
        if type(plugin.for_cat) == "string" then
          plugin.enabled = nixInfo(false, "settings", "cats", plugin.for_cat)
        end
      end
      return plugin
    end,
  },

  nixInfo.lze.lsp,
}

-- Automagically setup filetype triggers for lsps if not provided
nixInfo.lze.h.lsp.set_ft_fallback(function(name)
  local lspcfg = nixInfo.get_mox_plugin_path "nvim-lspconfig"
  if lspcfg then
    local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
    return (ok and cfg or {}).filetypes or {}
  end
end)

---- Settings ----
vim.g.mapleader = " "
vim.g.maplocalleader = "§"

vim.o.number = true
vim.o.relativenumber = true
vim.wo.signcolumn = 'yes'
vim.wo.relativenumber = true
-- keep wrapped lines indented
vim.o.breakindent = true
-- save undo history
vim.o.undofile = true
-- ignore case when searching in lowercase
vim.o.ignorecase = true
vim.o.smartcase = true
-- crash/hang remedies
vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.completeopt = 'menu,preview,noselect'

vim.opt.scrolloff = 12
-- For When I come to a decision
-- vim.o.smarttab = true
-- vim.opt.cpoptions:append('I')
-- vim.o.expandtab = true
-- vim.o.smartindent = true
-- vim.o.autoindent = true
-- vim.o.tabstop = 4
-- vim.o.softtabstop = 4
-- vim.o.shiftwidth = 4

vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.cindent = true

---- Lazy Loading ----
---- Extensive Help From the nixCats Github
nixInfo.lze.load {
  {
    "nvim-treesitter",
    lazy = false,
    auto_enable = true,
  },
  {
    "nvim-treesitter-textobjects",
    lazy = false,
    auto_enable = true,
    before = function(plugin)
      vim.g.no_plugin_maps = true
    end,
  },
  {
    "mini.hipatterns",
    after = function(_)
      require('mini.hipatterns').setup({
        highlighters = {
          -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
          fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
          hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
          todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
          note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

          -- Highlight hex color strings (`#rrggbb`) using that color
          hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
        },
      })
    end,
  },
  {
    "nvim-lspconfig",
    auto_enable = true,
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
--    before = function(plugin)
--      vim.lsp.config('*', {
--        -- capabilities = capabilities,
--        on_attach = function(client, bufnr)
--          -- Your on_attach function should set buffer-local lsp related settings
--          local nmap = function(keys, func, desc)
--          if desc then desc = 'LSP: ' .. desc end
--          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
--          end
--          nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
--            nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
--          -- etc...
--      end,
--        })
--    end,
  },
  {
    "lazydev.nvim",
    auto_enable = true,
    cmd = { "LazyDev" },
    ft = "lua",
    after = function(_)
      require('lazydev').setup({
        library = {
          { words = { "nixInfo%.lze" }, path = nixInfo("lze", "plugins", "start", "lze") .. '/lua', },
          { words = { "nixInfo%.lze" }, path = nixInfo("lzextras", "plugins", "start", "lzextras") .. '/lua' },
        },
      })
    end,
  },
  {
    "blink.cmp",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_)
      require('blink.cmp').setup({
      keymap = { preset = 'default' },
      appearance = {},
      completion = {
        documentation = { auto_show = true },
      },
      fuzzy = {},
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "omni" },
        --providers = {
        --  lazydev = {
        --    name = "LazyDev",
        --    module = "lazydev.integrations.blink",
        --    score_offset = 100,
        --  },
        --},
      },
    })
    end,
  },
  {
    "autoclose.nvim",
    auto_enable = true,
    after = function(_)
      require('autoclose').setup()
    end

  },
  {
    "jdtls",
    for_cat = "java",
    lsp = {
      filetypes = { "java" },
    },
  },
  {
    -- name of the lsp
    "lua_ls",
    for_cat = "lua",
    -- provide a table containing filetypes,
    -- and then whatever your functions defined in the function type specs expect.
    -- in our case, it just expects the normal lspconfig setup options,
    -- but with a default on_attach and capabilities
    lsp = {
      -- if you provide the filetypes it doesn't ask lspconfig for the filetypes
      filetypes = { 'lua' },
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          formatters = {
            ignoreComments = true,
          },
          signatureHelp = { enabled = true },
          diagnostics = {
            globals = { "nixInfo", "vim", },
            disable = { 'missing-fields' },
          },
          telemetry = { enabled = false },
        },
      },
    },
  },
  {
    "nixd",
    enabled = nixInfo.isNix,
    for_cat = "nix",
    lsp = {
      filetypes = { "nix" },
      settings = {
        nixd = {
          nixpkgs = { expr = [[import <nixpkgs> {}]], },
          options = {
          },
          formatting = { command = { "nixfmt" }},
          diagnostics = { suppress = { "sema-escaping-with" }}
        },
      },
    },
  },
  {
    "qmlls",
    lsp = {
      filetypes = { "qml" },
    },
  },
}
