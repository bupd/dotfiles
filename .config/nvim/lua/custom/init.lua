vim.opt.colorcolumn = '80';
vim.opt.relativenumber = true

vim.cmd('set guicursor=n-v-c:block-Cursor-blinkwait1000-blinkon500-blinkoff300')

-- turn off swap file
vim.opt.swapfile = false

-- remove redundant whitespace
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

-- Auto-reindent and remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    -- Remove trailing whitespace
    vim.cmd([[%s/\s\+$//e]])
    -- Save the current cursor position
    local current_pos = vim.api.nvim_win_get_cursor(0)
    -- Reindent the entire file
    vim.cmd("normal! gg=G")
    -- Restore the cursor position
    vim.api.nvim_win_set_cursor(0, current_pos)
  end,
})
-- bupd
