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

-- Auto-format the file by running gg=G before every write
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  callback = function()
    vim.cmd("normal! gg=G")  -- Run gg=G to format the entire file
  end,
})
-- bupd

