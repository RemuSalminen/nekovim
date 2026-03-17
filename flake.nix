{
  description = "Nvim Config, Cat-style";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Plugins from outside nixpkgs ##
    plugins-lze = {
      url = "github:BirdeeHub/lze";
      flake = false;
    };
    plugins-lzextras = {
      url = "github:BirdeeHub/lzextras";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, wrappers, ... } @ inputs:
  let
    forEachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    module = nixpkgs.lib.modules.importApply ./module.nix inputs;
    wrapper = wrappers.lib.evalModule module;
  in
  {
    # Overlay pkgs neovim with the wrapped neovim
    overlays = {
      neovim = final: prev: { neovim = wrapper.config.wrap { pkgs = final; }; };
      default = self.overlays.neovim;
    };
    wrapperModules = {
      neovim = module;
      default = self.wrapperModules.neovim;
    };
    wrappers = {
      neovim = wrapper.config;
      default = self.wrappers.neovim;
    };
    # Make the Wraps into actual packages
    packages = forEachSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        neovim = wrapper.config.wrap { inherit pkgs; };
        default = self.packages.${system}.neovim;
      }
    );

    # Export NixOS and HomeManager modules
    nixosModules = {
      default = self.nixosModules.neovim;
      neovim = wrappers.lib.mkInstallModule {
        name = "neovim";
        value = module;
      };
    };
    homeModules = {
      default = self.homeModules.neovim;
      neovim = wrappers.lib.mkInstallModule {
        name = "neovim";
        value = module;
        loc = [
          "home"
          "packages"
        ];
      };
    };
  };
}
