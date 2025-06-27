require("supermaven-nvim").setup {
  keymaps = {
    accept_suggestion = "<C-]>", -- handled by nvim-cmp / blink.cmp
    clear_suggestion = "<C-c>",
    -- accept_word = "<C-]>",
  },
  -- ignore_filetypes = { cpp = true }, -- or { "cpp", }
  ignore_filetypes = { "cpp" }, -- or { "cpp", }
  color = {
    suggestion_color = "#ffffff",
    cterm = 244,
  },
  opts = {
    keymaps = {
      accept_suggestion = "<C-]>", -- handled by nvim-cmp / blink.cmp
      clear_suggestion = "<C-c>",
      -- accept_word = "<C-]>",
    },
    -- disable_inline_completion = true,
    ignore_filetypes = { "bigfile", "snacks_input", "snacks_notif" },
  },
  log_level = "info", -- set to "off" to disable logging completely
  disable_inline_completion = false, -- disables inline completion for use with cmp
  disable_keymaps = false, -- disables built in keymaps for more manual control
  condition = function()
    return false
  end, -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
}
