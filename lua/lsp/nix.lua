return {
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
}
