return {
  {
    "alpha-nvim",
    auto_enable = false,
    lazy = false,
    after = function(_)
      local dashboard = require('alpha.themes.dashboard')

      dashboard.section.header.val =
      {
        [[          *                  *␍␍                 ]],
        [[              __                *␍␍              ]],
        [[           ,db'    *     *␍␍                     ]],
        [[          ,d8/       *        *    *␍␍           ]],
        [[          888␍␍                                  ]],
        [[          `db\       *     *␍␍                   ]],
        [[            `o`_                    **␍␍         ]],
        [[       *               *   *    _      *␍␍       ]],
        [[             *                 / )␍␍             ]],
        [[          *    (\__/) *       ( (  *␍␍           ]],
        [[        ,-.,-.,)    (.,-.,-.,-.) ).,-.,-.␍␍      ]],
        [[       | @|  ={      }= | @|  / / | @|o |␍␍      ]],
        [[      _j__j__j_)     `-------/ /__j__j__j_␍␍     ]],
        [[      ________(               /___________␍␍     ]],
        [[       |  | @| \              || o|O | @|␍␍      ]],
        [[       |o |  |,'\       ,   ,'"|  |  |  |  hjw␍␍ ]],
        [[      vV\|/vV|`-'\  ,---\   | \Vv\hjwVv\//v␍␍    ]],
        [[                 _) )    `. \ /␍␍                ]],
        [[                (__/       ) )␍␍                 ]],
        [[                          (_/␍                   ]],
        [[------------------------------------------------␍]],
      }

      dashboard.section.buttons.val = {
        dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("f", "󰈞  Find Files", ":Telescope find_files <CR>"),
        dashboard.button("o", "󰋚  Recent Files", ":Telescope oldfiles <CR>"),
        dashboard.button("t", "󱎸  Find text", ":Telescope live_grep <CR>"),
        dashboard.button("q", "󰒲  Go Nap", ":qa <CR>"),
      }


      local function datetime_string()
        local datetime = os.date(" %d-%m-%Y %H:%M:%S")
        return datetime
      end

      local function version_string()
        local version = vim.version()
        local version_string = "v" .. version.major .. "." .. version.minor .. "." .. version.patch
        return version_string
      end

      local function execute(cmd)
        local f = assert(io.popen(cmd, "r"))
        local s = assert(f:read("*a"))
        f:close()
        return s
      end

      local function git_string()
        if vim.fn.executable("onefetch") ~= 1 then
          return nil
        end

        local git = execute(
          [[onefetch -d url --true-color never --no-art --no-color-palette --nerd-fonts 2>/dev/null | \
          sed 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g' | \
          awk '
          BEGIN { bar_length=30; fill="█"; half="▒"; empty="░" }
          {
            if ($1=="Language:") {
              for (b=1; b<=23; b++) bar = bar fill
              print $1 " " bar
              next
            }
            if ($1=="Languages:") {
              line = $1
              # Get Percentage Line
              if (getline nextline > 0) {
                valline = nextline
              }

              percentages_count = 0

              sacrifice_line = valline
              while (match(sacrifice_line, /([0-9]{1}|[0-9]{2}|[0-9]{3}).[0-9]{1}/)) {
                percentage = substr(sacrifice_line, RSTART, RLENGTH)
                percentages_count++
                percentages[percentages_count] = percentage + 0
                split(sacrifice_line, a, percentage)
                sacrifice_line = a[2]
              }

              for (i=1; i<=percentages_count; i++) {
                blocks[i] = int((percentages[i]/100)*bar_length + 0.5)
              }

              for (b=1; b<=blocks[1]; b++) bar = bar fill

              for (b=1; b<=blocks[2]; b++) bar = bar half

              remaining = bar_length - length(bar)
              for (i=1; i<=remaining; i++) bar = bar empty

              print $1 " " bar
              print valline
              next
            }
          print
          }']]
        )
        return git
      end


      local datetime_section = {
        type = "text",
        val = datetime_string,
        opts = {
          position = "center",
        },
      }

      local version_section = {
        type = "text",
        val = version_string,
        opts = {
          position = "center",
        },
      }

      local git_section = {
        type = "text",
        val = git_string,
        opts = {
          position = "center",
        },
      }

      local section = {
        header = dashboard.section.header,
        buttons = dashboard.section.buttons,
        footer = dashboard.section.footer,
        date = datetime_section,
        version = version_section,
        git = git_section,
      }

      local opts = {
        layout = {
          { type = "padding", val = 1 },
          section.header,
          section.date,
          { type = "padding", val = 2 },
          section.buttons,
          { type = "padding", val = 1 },
          section.footer,
          { type = "padding", val = 1 },
          section.git
        },
      }

      require('alpha').setup(opts)

      -- Hide Statusline
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = { "AlphaReady" },
        callback = function()
          vim.cmd([[ set laststatus=0 | autocmd BufUnload <buffer> set laststatus=3 ]])
        end,
      })

    end,
  },
}
