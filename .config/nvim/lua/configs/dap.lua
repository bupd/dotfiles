local dap_go = require "dap-go"
local dap = require "dap"
local dap_ui = require "dapui"

dap_go.setup()
-- For One
table.insert(dap.configurations.go, {
  type = "go",
  name = "One CONTAINER debugging",
  host = "localhost",
  port = 4001,
  mode = "remote",
  request = "attach",
  substitutePath = {
    -- only for mac pottais
    -- { from = '/opt/homebrew/Cellar/go/1.23.1/libexec', to = '/usr/local/go'},
    { from = "${workspaceFolder}", to = "/home/root/go/bin/dlv" },
  },
})

-- -- For Two
-- table.insert(dap.configurations.go, {
--   type = "delvetwo",
--   name = "Two CONTAINER debugging",
--   mode = "remote",
--   request = "attach",
--   substitutePath = {
--     -- { from = "/opt/homebrew/Cellar/go/1.23.1/libexec", to = "/usr/local/go" },
--     { from = "${workspaceFolder}", to = "dlv" },
--   },
-- })

-- adapters configuration
dap.adapters.go = {
  type = "server",
  host = "localhost",
  port = "4001",
}

-- dap.adapters.delvetwo = {
--   type = "server",
--   host = "127.0.0.1",
--   port = "2346",
-- }

dap_ui.setup {
  layouts = {
    {
      elements = {
        {
          id = "scopes",
          size = 0.35,
        },
        {
          id = "breakpoints",
          size = 0.30,
        },
        {
          id = "repl",
          size = 0.35,
        },
      },
      position = "right",
      size = 50,
    },
  },
}
