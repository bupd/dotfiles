local dap = require "dap"
local dap_go = require "dap-go"
local dap_ui = require "dapui"

-- Ensure delve is installed
require("mason-nvim-dap").setup {
  ensure_installed = { "delve" },
}

-- Setup dap-go for default local debugging configs
dap_go.setup()

-- Custom remote/local attach (manual dlv dap)
table.insert(dap.configurations.go, {
  type = "go",
  name = "Attach dlv basic goauth",
  request = "attach",
  mode = "remote", -- attach mode
  host = "127.0.0.1", -- dlv is running locally
  port = 4001, -- the port you ran dlv on
  cwd = "/home/bupd/code/pp/goauth", -- the folder dlv is running in
  -- No substitutePath needed, paths are identical
})

-- Remote harbor-core inside container
table.insert(dap.configurations.go, {
  type = "go",
  name = "Attach dlv harbor-core",
  request = "attach",
  mode = "remote",
  host = "127.0.0.1", -- host port-forward
  port = 4002, -- host port mapped to container 4001
  cwd = "/home/bupd/code/8gears/harbor/src/core", -- host source folder
  substitutePath = {
    { from = "/core", to = "/home/bupd/code/8gears/harbor/src/core" },
    -- container binary path → host source folder
  },
})

-- dap-ui setup
dap_ui.setup {
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.35 },
        { id = "breakpoints", size = 0.30 },
        { id = "repl", size = 0.35 },
      },
      position = "right",
      size = 50,
    },
  },
}

-- local dap_go = require "dap-go"
-- local dap = require "dap"
-- local dap_ui = require "dapui"
--
-- require("mason-nvim-dap").setup({
--     ensure_installed = { "delve" }
-- })
--
-- dap_go.setup()
-- -- For One
-- table.insert(dap.configurations.go, {
--   type = "go",
--   name = "One CONTAINER debugging",
--   host = "localhost",
--   port = 4001,
--   mode = "remote",
--   request = "attach",
--   substitutePath = {
--     -- only for mac pottais
--     -- { from = '/opt/homebrew/Cellar/go/1.23.1/libexec', to = '/usr/local/go'},
--     { from = "${workspaceFolder}", to = "/home/root/go/bin/dlv" },
--   },
-- })
--
-- -- -- For Two
-- -- table.insert(dap.configurations.go, {
-- --   type = "delvetwo",
-- --   name = "Two CONTAINER debugging",
-- --   mode = "remote",
-- --   request = "attach",
-- --   substitutePath = {
-- --     -- { from = "/opt/homebrew/Cellar/go/1.23.1/libexec", to = "/usr/local/go" },
-- --     { from = "${workspaceFolder}", to = "dlv" },
-- --   },
-- -- })
--
-- -- adapters configuration
-- dap.adapters.go = {
--   type = "server",
--   host = "localhost",
--   port = "4001",
-- }
--
-- -- dap.adapters.delvetwo = {
-- --   type = "server",
-- --   host = "127.0.0.1",
-- --   port = "2346",
-- -- }
--
-- dap_ui.setup {
--   layouts = {
--     {
--       elements = {
--         {
--           id = "scopes",
--           size = 0.35,
--         },
--         {
--           id = "breakpoints",
--           size = 0.30,
--         },
--         {
--           id = "repl",
--           size = 0.35,
--         },
--       },
--       position = "right",
--       size = 50,
--     },
--   },
-- }
