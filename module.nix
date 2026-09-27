inputs: { config, wlib, lib, pkgs, options, ... }:

{
  imports = [ wlib.wrapperModules.neovim ];

  options.nvim-lib = {
    # build plugins from inputs set
    pluginsFromPrefix = lib.mkOption {
      type = lib.types.raw;
      readOnly = true;
      default =
        prefix: inputs:
        lib.pipe inputs [
          builtins.attrNames
          (builtins.filter (s: lib.hasPrefix prefix s))
          (map (
            input:
            let
              name = lib.removePrefix prefix input;
            in
            {
              inherit name;
              value = config.nvim-lib.mkPlugin name inputs.${input};
            }
          ))
          builtins.listToAttrs
        ];
    };

    neovimPlugins = lib.mkOption {
      readOnly = true;
      type = lib.types.attrsOf wlib.types.stringable;
      default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
    };
  };

  config.settings.config_directory = ./.;

  options.settings = {
    # Enabled Specs (for cat(egories)s)
    cats = lib.mkOption {
      readOnly = true;
      type = lib.types.attrsOf lib.types.bool;
      default = builtins.mapAttrs (_: v: v.enable) config.specs;
    };

    colorscheme = lib.mkOption {
      type = lib.types.str;
      default = "neopywal";
    };
  };

  config.binName = "nekovim";
  #config.settings.aliases = [ "vim" "nvim" ];


  config = {
    # Get pkgs from each spec
    runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];
    ## Specs are nixCats categories?
    specs = {
      lze = [
        config.nvim-lib.neovimPlugins.lze
        {
          data = config.nvim-lib.neovimPlugins.lzextras;
          name = "lzextras";
        }
      ];
      general = {
        after = [ "lze" ];
        ## Pkgs not directly related to nvim; Stuff to package with it.
        runtimePkgs = with pkgs; [
          ripgrep
          lazygit
          tree-sitter
          onefetch
        ];

        lazy = true;

        data = with pkgs.vimPlugins; [
          alpha-nvim

          nvim-treesitter-textobjects
          nvim-treesitter.withAllGrammars

          telescope-fzf-native-nvim
          telescope-frecency-nvim
          neo-tree-nvim

          nvim-lspconfig
          blink-cmp
          blink-compat
          mini-hipatterns
          autoclose-nvim
          neoscroll-nvim
          which-key-nvim
        ];
      };
      colorscheme = {
        lazy = true;
        data = builtins.getAttr config.settings.colorscheme (
          {
            # Base16 colorscheme that auto refreshes.
            "neopywal" = config.nvim-lib.neovimPlugins.neopywal;
            "neopywal-dark" = config.nvim-lib.neovimPlugins.neopywal;
            "neopywal-light" = config.nvim-lib.neovimPlugins.neopywal;
          }

          //

          (with pkgs.vimPlugins;
          {
            "onedark" = onedarkpro-nvim;
            "onelight" = onedarkpro-nvim;
            "onedark_dark" = onedarkpro-nvim;
            "onedark_vivid" = onedarkpro-nvim;
          })
        );
      };
      markdown = {
        after = [ "general" ];
        lazy = true;
        runtimePkgs = with pkgs; [
          python3Packages.pylatexenc
          imagemagick
          luajitPackages.magick
        ];
        data = with pkgs.vimPlugins; [
          render-markdown-nvim
          image-nvim
        ];
      };
      nix = {
        after = [ "general" ];
        lazy = true;
        runtimePkgs = with pkgs; [
          nixd
          nixfmt
        ];
        data = null;
      };
      lua = {
        after = [ "general" ];
        lazy = true;
        runtimePkgs = with pkgs; [
          lua-language-server
          stylua
        ];
        data = with pkgs.vimPlugins; [
          lazydev-nvim
        ];
      };
      java = {
        after = [ "general" ];
        lazy = true;
        runtimePkgs = with pkgs; [
          jdt-language-server
        ];
        data = with pkgs.vimPlugins; [
          nvim-jdtls
        ];
      };
      lean = {
        after = [ "general" ];
        lazy = true;
        runtimePkgs = with pkgs; [
        ];
        data = with pkgs.vimPlugins; [
          lean-nvim
        ];
      };
      python = {
        after = [ "general" ];
        lazy = true;
        runtimePkgs = with pkgs; [
          ty
          ruff
        ];
        data = null;
      };
    };
    # To be able to modify specs from outside the Module.
    ## "parent" refers to the Original values.
    specMods = { parentSpec ? null, parentOpts ? null, parentName ? null, config, ... }: {
      # add a runtimePkgs field to the specs themselves
      options.runtimePkgs = options.runtimePkgs // {
        description = ''
          A runtimePkgs spec field to put packages on the PATH
          If the spec is disabled, this value will not be included in the resulting neovim derivation
        '';
      };
    };
    #settings = {};
  };
}

# https://github.com/BirdeeHub/nix-wrapper-modules/blob/main/templates/neovim/module.nix
