return {
  {
    "3rd/image.nvim",
    ft = { "markdown" },
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
        },
      },
      max_width = 80,
      max_height = 20,
      max_height_window_percentage = 50,
      max_width_window_percentage = 50,
    },
  },
}
