require("supermaven-nvim").setup {
  keymaps = {
    accept_suggestion = "<Right>",
    clear_suggestion = "<C-c>",
    accept_word = "<C-]>",
  },
  -- ignore_filetypes = { cpp = true }, -- or { "cpp", }
  ignore_filetypes = { "cpp", "bigfile", "snacks_input", "snacks_notif" }, -- or { "cpp", }
  color = {
    suggestion_color = "#ffffff",
    cterm = 244,
  },
  log_level = "info", -- set to "off" to disable logging completely
  disable_inline_completion = false, -- disables inline completion for use with cmp
  disable_keymaps = false, -- disables built in keymaps for more manual control
  condition = function()
    return false
  end, -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
}
