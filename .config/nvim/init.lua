require "core"

-- put this in your main init.lua file ( before lazy setup )
-- vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46_cache/"

-- -- (method 2, for non lazyloaders) to load all highlights at once
-- for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
-- 	dofile(vim.g.base46_cache .. v)
-- end
local custom_init_path = vim.api.nvim_get_runtime_file("lua/custom/init.lua", false)[1]

if custom_init_path then
  dofile(custom_init_path)
end

require("core.utils").load_mappings()

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
  require("core.bootstrap").gen_chadrc_template()
  require("core.bootstrap").lazy(lazypath)
end

dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")
vim.opt.rtp:prepend(lazypath)
require "plugins"

-- put this after lazy setup
-- (method 1, For heavy lazyloaders)
-- dofile(vim.g.base46_cache .. "defaults")
-- dofile(vim.g.base46_cache .. "statusline")
