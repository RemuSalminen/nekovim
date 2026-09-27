return {
  {
    "render-markdown.nvim",
    for_cat = "markdown",
    ft = "markdown",
    after = function(_)
      require("render-markdown").setup({})
    end,
  },
  {
    "image.nvim",
    for_cat = "markdown",
    ft = "markdown",
    after = function (_)
      require("image").setup({
        processor = "magick_rock",
        integrations = {
          markdown = {
            clear_in_insert_mode = true,
            only_render_image_at_cursor = true,
            only_render_image_at_cursor_mode = "inline",
          },
        },
      })
    end,
  },
}
