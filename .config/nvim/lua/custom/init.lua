vim.opt.colorcolumn = "80"
vim.opt.relativenumber = true

vim.cmd("set guicursor=n-v-c:block-Cursor-blinkwait1000-blinkon500-blinkoff300")

-- turn off swap file
vim.opt.swapfile = false


-- remove redundant trailing whitespace
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	pattern = { "*" },
	command = [[%s/\s\+$//e]],
})

-- jump to errors
vim.keymap.set("n", "]g", vim.diagnostic.goto_next)
vim.keymap.set("n", "[g", vim.diagnostic.goto_prev)

-- Remove current item from quickfix list and adjust navigation
function RemoveQFItem()
	-- Get the current quickfix list and current line index
	local qfall = vim.fn.getqflist()
	local curqfidx = vim.fn.line(".") - 1 -- current quickfix index

	-- Remove the current item from the quickfix list
	table.remove(qfall, curqfidx + 1) -- Lua is 1-indexed, hence `+1`

	-- Update the quickfix list
	vim.fn.setqflist(qfall, "r")

	-- Move to the next item or the previous one after removing an item
	if curqfidx >= #qfall then
		vim.cmd("cprev") -- If we're at the last item, go to the previous item
	else
		vim.cmd("cfirst") -- Otherwise, go to the first item after removal
	end
end

-- Create a command to call the function
vim.api.nvim_create_user_command("RemoveQFItem", RemoveQFItem, {})

-- Autocommand for mapping 'dd' only in quickfix window
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		vim.api.nvim_buf_set_keymap(0, "n", "dd", ":RemoveQFItem<CR>", { noremap = true, silent = true })
	end,
})

-- Helpful keymaps for Git operations
vim.keymap.set("n", "<leader>gG", ":Git<CR>")
vim.keymap.set("n", "<leader>gd", ":Gdiffsplit<CR>")
vim.keymap.set("n", "<leader>gc", ":Git commit<CR>")
vim.keymap.set("n", "<leader>gB", ":Git blame<CR>")
vim.keymap.set("n", "<leader>gm", ":Git mergetool<CR>")

-- Improve diff experience
vim.opt.diffopt:append("algorithm:patience")
vim.opt.diffopt:append("indent-heuristic")

-- -- Auto-reindent and remove trailing whitespace on save
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*",
--   callback = function()
--     -- Remove trailing whitespace
--     vim.cmd([[%s/\s\+$//e]])
--     -- Save the current cursor position
--     local current_pos = vim.api.nvim_win_get_cursor(0)
--     -- Reindent the entire file
--     vim.cmd("normal! gg=G")
--     -- Restore the cursor position
--     vim.api.nvim_win_set_cursor(0, current_pos)
--   end,
-- })
-- bupd
