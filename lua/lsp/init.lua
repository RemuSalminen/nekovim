nixInfo.lze.register_handlers {
  nixInfo.lze.lsp
}

-- Automagically setup filetype triggers for lsps if not provided
nixInfo.lze.h.lsp.set_ft_fallback(function(name)
  local lspcfg = nixInfo.get_mox_plugin_path "nvim-lspconfig"
  if lspcfg then
    local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
    return (ok and cfg or {}).filetypes or {}
  end
end)

nixInfo.lze.load {
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
  { import = "lsp.lua" },
  { import = "lsp.nix" },
  { import = "lsp.java" },
  { import = "lsp.qml" },
}
