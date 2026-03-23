local winwidth = 30

-- Toggle width.
local toggle_width = function()
  local max = winwidth * 2
  local cur_width = vim.fn.winwidth(0)
  local half = math.floor((winwidth + (max - winwidth) / 2) + 0.4)
  local new_width = winwidth
  if cur_width == winwidth then
    new_width = half
  elseif cur_width == half then
    new_width = max
  else
    new_width = winwidth
  end
  vim.cmd(new_width .. ' wincmd |')
end

-- Get current opened directory from state.
---@param state table
---@return string
local function get_current_directory(state)
  local node = state.tree:get_node()
  local path = node.path
  if node.type ~= 'directory' or not node:is_expanded() then
    local path_separator = package.config:sub(1, 1)
    path = path:match('(.*)' .. path_separator)
  end
  return path
end

local root_names = { '.git', 'Makefile' }
local root_cache = {}
local function get_root_directory()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then return end
  path = vim.fs.dirname(path)

  local root = root_cache[path]
  if root == nil then
    local root_file = vim.fs.find(root_names, { path = path, upward = true })[1]
    if root_file == nil then return end
    root = vim.fs.dirname(root_file)
    root_cache[path] = root
  end

  return root
end

return {
  {
    "neo-tree.nvim",
    lazy = true,
    cmd = 'Neotree',
    keys = {
      {
        '<leader>fe',
        function()
          require('neo-tree.command').execute({
            toggle = true,
            dir = get_root_directory()
          })
        end,
        desc = 'Explorer NeoTree (root dir)',
      },
      {
        '<leader>fE',
        function()
          require('neo-tree.command').execute({ toggle = true, dir = vim.loop.cwd() })
        end,
        desc = 'Explorer NeoTree (cwd)',
      },
      {
        '<LocalLeader>a',
        function()
          require('neo-tree.command').execute({
            reveal = true,
            dir = get_root_directory()
          })
        end,
        desc = 'Explorer NeoTree Reveal',
      },
      { '<LocalLeader>e', '<leader>fe', desc = 'Explorer NeoTree (root dir)', remap = true },
      { '<leader>e', '<leader>fe', desc = 'Explorer NeoTree (root dir)', remap = true },
      { '<leader>E', '<leader>fE', desc = 'Explorer NeoTree (cwd)', remap = true },
      {
        '<leader>ge',
        function()
          require('neo-tree.command').execute({ source = 'git_status', toggle = true })
        end,
        desc = 'Git explorer',
      },
      {
        '<leader>be',
        function()
          require('neo-tree.command').execute({ source = 'buffers', toggle = true })
        end,
        desc = 'Buffer explorer',
      },
      {
        '<leader>xe',
        function()
          require('neo-tree.command').execute({ source = 'document_symbols', toggle = true })
        end,
        desc = 'Document explorer',
      },
    },
    beforeAll = function()
      if vim.fn.argc(-1) == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == 'directory' then
          require('neo-tree')
        end
      end
    end,
    -- See: https://github.com/nvim-neo-tree/neo-tree.nvim
    opts = {
    },
    after = function(_)
      local function on_move(data)
        require('lze').lsp.on_rename(data.source, data.destination)
      end

      vim.api.nvim_create_autocmd('TermClose', {
        pattern = '*lazygit',
        callback = function()
          if package.loaded['neo-tree.sources.git_status'] then
            require('neo-tree.sources.git_status').refresh()
          end
        end,
      })

      require('neo-tree').setup({
        close_if_last_window = true,
        sources = { 'filesystem', 'buffers', 'git_status', 'document_symbols' },
        open_files_do_not_replace_types = { 'terminal', 'Trouble', 'trouble', 'qf', 'Outline' },

        source_selector = {
          winbar = false,
          show_scrolled_off_parent_node = true,
          padding = { left = 1, right = 0 },
          sources = {
            { source = 'filesystem', display_name = '  Files' },   --       
            { source = 'buffers',    display_name = '  Buffers' }, --        
            { source = 'git_status', display_name = ' 󰊢 Git' },     -- 󰊢      
          },
        },

        event_handlers = {
          -- Close neo-tree when opening a file.
          {
            event = 'file_opened',
            handler = function()
              require('neo-tree.command').execute({ action = 'close' })
            end,
          },
          { event = 'file_moved', handler = on_move },
          { event = 'file_renamed', handler = on_move },
        },

        default_component_configs = {
          indent = {
            expander_collapsed = '',
            expander_expanded = '',
            expander_highlight = 'NeoTreeExpander',
          },
          icon = {
            folder_closed = '',
            folder_open = '',
            folder_empty = '',
            folder_empty_open = '',
            default = '',
          },
          modified = {
            symbol = '•',
          },
          name = {
            trailing_slash = true,
            highlight_opened_files = true, -- NeoTreeFileNameOpened
            use_git_status_colors = false,
          },
          git_status = {
            symbols = {
              -- Change type
              added = 'A',
              deleted = 'D',
              modified = 'M',
              renamed = 'R',
              -- Status type
              untracked = 'U',
              ignored = 'I',
              unstaged = '',
              staged = 'S',
              conflict = 'C',
            },
          },
        },
        window = {
          width = winwidth,
          mappings = {
            ['q'] = 'close_window',
            ['?'] = 'noop',
            ['<Space>'] = 'noop',

            ['g?'] = 'show_help',
            ['<2-LeftMouse>'] = 'open',
            ['<CR>'] = 'open_with_window_picker',
            ['l'] = 'open_drop',
            ['h'] = 'close_node',
            ['C'] = 'close_node',
            ['z'] = 'close_all_nodes',
            ['<C-r>'] = 'refresh',

            ['s'] = 'noop',
            ['sv'] = 'open_split',
            ['sg'] = 'open_vsplit',
            ['st'] = 'open_tabnew',

            ['<S-Tab>'] = 'prev_source',
            ['<Tab>'] = 'next_source',

            ['p'] = {
              'toggle_preview',
              nowait = true,
              config = { use_float = true },
            },
            ['w'] = toggle_width,
          },
        },
        filesystem = {
          window = {
            mappings = {
              ['d'] = 'noop',
              ['dd'] = 'delete',
              ['c'] = { 'copy', config = { show_path = 'relative' } },
              ['m'] = { 'move', config = { show_path = 'relative' } },
              ['a'] = { 'add', nowait = true, config = { show_path = 'relative' } },
              ['N'] = { 'add_directory', config = { show_path = 'relative' } },
              ['r'] = 'rename',
              ['y'] = 'copy_to_clipboard',
              ['x'] = 'cut_to_clipboard',
              ['P'] = 'paste_from_clipboard',

              ['H'] = 'toggle_hidden',
              ['/'] = 'noop',
              ['f'] = 'fuzzy_finder',
              ['F'] = 'filter_on_submit',
              ['<C-x>'] = 'clear_filter',
              ['<C-c>'] = 'clear_filter',
              ['<BS>'] = 'navigate_up',
              ['.'] = 'set_root',
              ['[g'] = 'prev_git_modified',
              [']g'] = 'next_git_modified',

              ['gf'] = function(state)
                require('telescope.builtin').find_files({
                  cwd = get_current_directory(state),
                })
              end,

              ['gr'] = function(state)
                require('telescope.builtin').live_grep({
                  cwd = get_current_directory(state),
                })
              end,
            },
          },
          group_empty_dirs = true,
          use_libuv_file_watcher = true,
          bind_to_cwd = false,
          cwd_target = {
            sidebar = 'window',
            current = 'window',
          },

          filtered_items = {
            visible = false,
            show_hidden_count = false,
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_by_name = {
              '.git',
              '.hg',
              '.svc',
              '.DS_Store',
              'thumbs.db',
              '.sass-cache',
              'node_modules',
              '.pytest_cache',
              '.mypy_cache',
              '__pycache__',
              '.stfolder',
              '.stversions',
            },
            never_show = {},
          },
        },
        buffers = {
          bind_to_cwd = false,
          window = {
            mappings = {
              ['<BS>'] = 'navigate_up',
              ['.'] = 'set_root',
              ['dd'] = 'buffer_delete',
            },
          },
        },
        git_status = {
          window = {
            mappings = {
              ['d'] = 'noop',
              ['dd'] = 'delete',
            },
          },
        },
        document_symbols = {
          follow_cursor = true,
        },
      })
    end,
  },
}
