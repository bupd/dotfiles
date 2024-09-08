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

-- bupd

