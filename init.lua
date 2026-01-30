-- Settings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.number = true
vim.o.relativenumber = true

-- Lazy Loading
---- Extensive Help From the nixCats Github
require('lze').register_handlers(require('lzextras').lsp)
--local old_ft_fallback = require('lze').h.lsp.get_ft_fallback()
--require('lze').h.lsp.set_ft_fallback(function(name)
--  local lspcfg = nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" }) or nixCats.pawsible({ "allPlugins", "start", "nvim-lspconfig" })
--  if lspcfg then
--    local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
--    if not ok then
--      ok, cfg = pcall(dofile, lspcfg .. "/lua/lspconfig/configs/" .. name .. ".lua")
--    end
--    return (ok and cfg or {}).filetypes or {}
--  else
--    return old_ft_fallback(name)
--  end
--end)
require('lze').load {
	{
		"nvim-treesitter",
		lazy = false,
	},
	{
		"nvim-treesitter-textobjects",
		lazy = false,
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
		on_require = { "lspconfig" },
		lsp = function(plugin)
			vim.lsp.config(plugin.name, plugin.lsp or {})
			vim.lsp.enable(plugin.name)
		end,
--		before = function(plugin)
--			vim.lsp.config('*', {
--				-- capabilities = capabilities,
--				on_attach = function(client, bufnr)
--				  -- Your on_attach function should set buffer-local lsp related settings
--					local nmap = function(keys, func, desc)
--					if desc then desc = 'LSP: ' .. desc end
--					vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
--					end
--					nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
--				  	nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
--					-- etc...
--			end,
--     		})
--		end,
	},
	{
		"lazydev.nvim",
		cmd = { "LazyDev" },
		ft = "lua",
		after = function(_)
			require('lazydev').setup({
				library = {
					{ words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. '/lua' },
				},
			})
		end,
	},
	{
		"blink.cmp",
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
				--	lazydev = {
				--		name = "LazyDev",
				--		module = "lazydev.integrations.blink",
				--		score_offset = 100,
				--	},
				--},
			},
		})
		end,
	},
	{
	    -- name of the lsp
	    "lua_ls",
	    enabled = true,
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
	            globals = { "nixCats", "vim", },
	            disable = { 'missing-fields' },
	          },
	          telemetry = { enabled = false },
	        },
	      },
	    },
    	},
	{
		"nixd",
		lsp = {
			filetypes = { "nix" },
			settings = {
				nixd = {
					nixpkgs = { expr = nixCats.extra("nixdExtras.nixpkgs"), },
					options = {
						nixos = { expr = nixCats.extra("nixdExtras.nixos"), },
						["home-manager"] = { expr = nixCats.extra("nixdExtras.home-manager"), },
					},
					formatting = { command = { "nixfmt" }},
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
