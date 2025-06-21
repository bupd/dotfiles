dofile(vim.g.base46_cache .. "nvimtree")

return {
  filters = {
    dotfiles = false,
    custom = {},
    exclude = {},
  },
  disable_netrw = false,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  view = {
    width = 30,
    preserve_window_proportions = false,
  },
  git = {
    enable = true,
    ignore = false,
    timeout = 400,
  },
  renderer = {
    root_folder_label = false,
    highlight_git = true,
    indent_markers = { enable = true },
    icons = {
      glyphs = {
        default = "󰈚",
        folder = {
          default = "",
          empty = "",
          empty_open = "",
          open = "",
          symlink = "",
        },
        git = { unmerged = "" },
      },
    },
  },
}
