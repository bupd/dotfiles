vim.opt.colorcolumn = '80';
vim.opt.relativenumber = true
-- vim.opt.undolevels=100
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- the above handles the undotree plugin levels of undotree.
-- now its set to 100 check :help 'undolevels' for more info.

vim.cmd('set guicursor=n-v-c:block-Cursor-blinkwait1000-blinkon500-blinkoff300')

