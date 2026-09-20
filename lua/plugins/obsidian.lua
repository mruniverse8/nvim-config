return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "v3.16.3",
    cmd = "Obsidian",
    ft = "markdown",
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "personal",
          path = "~/vaults/personal",
        },
      },
      notes_subdir = "notes",
      new_notes_location = "notes_subdir",
    },
  },
}
