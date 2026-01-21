{
  description = "Nvim Config, Cat-style";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = { self, nixpkgs, nixCats, ... } @ inputs:
  let
	inherit (nixCats) utils;
	# Where Nvim should find the lua dir
	luaPath = ./.;
 
	forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;

	# Values to pass to the config of nixpkgs
	extra_pkg_config = {};

	# Import packages from inputs
	## Defined: plugins-<pluginName> = { ... }
	## Accessed: pkgs.neovimPlugins
	# :help nixCats.flake.outputs.overlays
	dependencyOverlays = [ (utils.standardPluginOverlay inputs) ];

	# Categories are pkg groups that can be toggled on and off
	## :help nixCats.flake.outputs.categories & --.outputs.categoryDefinitions.scheme
	categoryDefinitions = { pkgs, settings, categories, extra, name, mkPlugin } @ packageDef: {
		# RUNTIME dependencies to add (to PATH) for plugins
		lspsAndRuntimeDeps = {
			general = with pkgs; [
				
			];
		};

		startupPlugins = {
			general = with pkgs.vimPlugins; [];
			gitPlugins = with pkgs.neovimPlugins; [];
		};

		# Plugins to lazy load (with whatever method used)
		optionalPlugins = {
			general = with pkgs.vimPlugins; [];
		};

		# Added to LD_LIBRARY_PATH
		## No idea what that means in practice rn
		sharedLibraries = {
			general = with pkgs; [];
		};

		# RUNTIME envVars for Plugins and Nvim instances
		environmentVariables = {};

		# nixpkgs option
		extraWrapperArgs = {};

		# Extra Functions to pass to python.withPackages or lua.withPackages
		## Enabled by setting hosts.python3.enable
		## Accessible in lua config via vim.g.python3_host_prog
		python3.libraries = {};
		## Added to $LUA_PATH & $LUA_CPATH
		extraLuaPackages = {};
	};

	# Define the Package itself
	# Queriable from lua
	# :help nixCats.flake.outputs.packageDefinitions
	defaultPackageName = "nekovim";
	packageDefinitions = {
		# Can Define Multiple "Versions"
		nekovim = { pkgs, name, ... }: {
			# :help nixCats.flake.outputs.settings
			settings = {
				suffix-path = true;
				suffix-LD = true;
				wrapRc = true;
				# package-wide unique Alias
				aliases = [ "vim" ];
			};
			# Categories to enable
			## Also additional information to pass to lua (strings, sets...)
			categories = {
				general = true;
			};
		};
	};
  in
  # :help nixCats.flake.outputs.exports
  forEachSystem (system:
  let
  	nixCatsBuilder = utils.baseBuilder luaPath {
  		inherit nixpkgs dependencyOverlays extra_pkg_config;
  	} categoryDefinitions packageDefinitions;
  	defaultPackage = nixCatsBuilder defaultPackageName;
  	pkgs = import nixpkgs { inherit system; };
  in
  {
  	# Make the packageDefinitions into actual packages. Set the default
  	packages = utils.mkAllWithDefault defaultPackage;
  
  	# Choose devShell package
  	devShells = {
  		default = pkgs.mkShell {
  			name = defaultPackageName;
  			packages = [ defaultPackage ];
  			inputsFrom = [];
  			shellHook = '''';
  		};
  	};
  })

  # Export NixOS and HomeManager modules
  (let
  	nixosModule = utils.mkNixosModules {
		moduleNamespace = [ defaultPackageName ];
		inherit defaultPackageName dependencyOverlays luaPath
			categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
	};
	homeModule = utils.mkHomeModules {
		moduleNamespace = [ defaultPackageName ];
		inherit defaultPackageName dependencyOverlays luaPath
			categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
	};
  in
  {
	overlays = utils.makeOverlays luaPath {
		inherit nixpkgs dependencyOverlays extra_pkg_config;
	} categoryDefinitions packageDefinitions defaultPackageName;

	nixosModules.default = nixosModule;
	homeModules.default = homeModule;

	inherit utils nixosModule homeModule;
	inherit (utils) templates;
  });
}
