require "nvchad.mappings"
-- require "nvchad.options"

-- add yours here

local map = vim.keymap.set
-- local opt = vim.opt_global

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
-- map("n", "<C-n>", "<cmd>lua vim.diagnostic.jump { count = -1, float = true }<CR>", opt)
-- map("n", "<C-p>", "<cmd>lua vim.diagnostic.jump { count = 1, float = true }<CR>", opt)

map({ "n", "i", "v" }, "<C-c>", "<ESC>")

-- Gitsigns: Navigation through hunks
map("n", "]c", function()
	if vim.wo.diff then return "]c" end
	vim.schedule(function()
		require("gitsigns").next_hunk()
	end)
	return "<Ignore>"
end, { expr = true, desc = "Jump to next hunk" })

map("n", "[c", function()
	if vim.wo.diff then return "[c" end
	vim.schedule(function()
		require("gitsigns").prev_hunk()
	end)
	return "<Ignore>"
end, { expr = true, desc = "Jump to prev hunk" })

-- Gitsigns: Actions
map("n", "<leader>gH", function()
	require("gitsigns").reset_hunk()
end, { desc = "Reset hunk" })

map("n", "<leader>gh", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview hunk" })

map("n", "<leader>gu", function()
	require("gitsigns").undo_stage_hunk()
end, { desc = "Undo Stage Hunk" })

map("n", "<leader>ga", function()
	require("gitsigns").stage_hunk()
end, { desc = "Stage Hunk" })

map("n", "<leader>gS", function()
	require("gitsigns").stage_buffer()
end, { desc = "Stage Buffer" })

map("n", "<leader>gU", function()
	require("gitsigns").reset_buffer()
end, { desc = "Reset Buffer" })

map("n", "<leader>gb", function()
	require("gitsigns").blame_line()
end, { desc = "Blame line" })

map("n", "<leader>gtd", function()
	require("gitsigns").toggle_deleted()
end, { desc = "Toggle deleted" })

-- General mappings
map("n", "<C-h>", "<cmd> TmuxNavigateLeft<CR>", { desc = "window left" })
map("n", "<C-l>", "<cmd> TmuxNavigateRight<CR>", { desc = "window right" })
map("n", "<C-j>", "<cmd> TmuxNavigateDown<CR>", { desc = "window down" })

-- Toggle undotree
map("n", "<leader>u", "<cmd> UndotreeToggle <CR>", { desc = "Toggle undotree" })
