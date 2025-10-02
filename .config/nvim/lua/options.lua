require "nvchad.options"

vim.opt.colorcolumn = "80"
vim.opt.relativenumber = true
-- set cursor blink
vim.cmd("set guicursor=n-v-c:block-Cursor-blinkwait1000-blinkon500-blinkoff300")
-- turn off swap file
vim.opt.swapfile = false

vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- -- remove redundant trailing whitespace
-- vim.api.nvim_create_autocmd({ "BufWritePre" }, {
--   pattern = { "*" },
--   command = [[%s/\s\+$//e]],
-- })
-- Remove trailing whitespace in mardoown only
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*", -- apply to all files initially
  callback = function()
    -- Ignore markdown files
    if vim.bo.filetype == "markdown" then
      return
    end

    -- Remove trailing whitespace
    vim.cmd([[%s/\s\+$//e]])
  end,
})

-- jump to errors
vim.keymap.set("n", "]g", vim.diagnostic.goto_next)
vim.keymap.set("n", "[g", vim.diagnostic.goto_prev)

-- Resize quickfix window height
vim.keymap.set("n", "<leader>=", ":resize +5<CR>", { desc = "Increase quickfix height" })
vim.keymap.set("n", "<leader>-", ":resize -5<CR>", { desc = "Decrease quickfix height" })

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
    vim.cmd("cprev")  -- If we're at the last item, go to the previous item
  else
    vim.cmd("cfirst") -- Otherwise, go to the first item after removal
  end
end

-- Create a command to call the function
vim.api.nvim_create_user_command("RemoveQFItem", RemoveQFItem, {})

-- Autocommand for mapping 'dd' only in quickfix list
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

-- autocmds
local autocmd = vim.api.nvim_create_autocmd

-- This autocmd will restore cursor position on file open
autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line("'\"")
    if
        line > 1
        and line <= vim.fn.line("$")
        and vim.bo.filetype ~= "commit"
        and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
    then
      vim.cmd('normal! g`"')
    end
  end,
})

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Show Nvdash when all buffers are closed
-- vim.api.nvim_create_autocmd("BufDelete", {
-- 	callback = function()
-- 		local bufs = vim.t.bufs
-- 		if #bufs == 1 and vim.api.nvim_buf_get_name(bufs[1]) == "" then
-- 			vim.cmd("Nvdash")
-- 		end
-- 	end,
-- })

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

-- add yours here!

-- o.cursorlineopt ='both' -- to enable cursorline!
-- local o = vim.o
--
-- vim.g.mapleader = " "
--
-- o.laststatus = 3 -- global statusline
-- o.showmode = false
-- o.swapfile = false
--
-- -- o.clipboard = "unnamedplus"
--
-- -- Indenting
-- o.expandtab = true
-- o.shiftwidth = 2
-- o.smartindent = true
-- o.tabstop = 2
-- o.softtabstop = 2
-- o.scrolloff = 8
-- o.sidescrolloff = 8
--
-- vim.opt.fillchars = { eob = " " }
-- o.ignorecase = true
-- o.smartcase = true
-- o.mouse = "a"
--
-- -- o.number = true
--
-- o.signcolumn = "yes"
-- o.splitbelow = true
-- o.splitright = true
-- o.termguicolors = true
-- o.timeoutlen = 400
-- o.undofile = true
-- o.cursorline = true
--
-- -- add binaries installed by mason.nvim to path
-- local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
-- vim.env.PATH = vim.env.PATH .. (is_windows and ";" or ":") .. vim.fn.stdpath("data") .. "/mason/bin"
--
-- vim.api.nvim_set_hl(0, "IndentLine", { link = "Comment" })
--
-- -- Inlay hints
vim.lsp.inlay_hint.enable(true)
--
