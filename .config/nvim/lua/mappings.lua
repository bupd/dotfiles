require "nvchad.mappings"
-- require "nvchad.options"

-- add yours here

local map = vim.keymap.set
-- local opt = vim.opt_global

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
-- map("n", "<C-n>", "<cmd>lua vim.diagnostic.jump { count = -1, float = true }<CR>", opt)
-- map("n", "<C-p>", "<cmd>lua vim.diagnostic.jump { count = 1, float = true }<CR>", opt)

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
