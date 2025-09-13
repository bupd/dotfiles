require("dap-go").setup {
  -- Additional dap configurations can be added.
  -- dap_configurations accepts a list of tables where each entry
  -- represents a dap configuration. For more details do:
  -- :help dap-configuration
  dap_configurations = {
    {
      type = "go",
      name = "Remote via Pod (DAP proxy)",
      request = "launch", -- launch instead of attach
      mode = "exec", -- run an already compiled binary
      program = "/home/bupd/code/8gears/harbor/bin/core", -- local binary path
      cwd = "${workspaceFolder}",
      host = "127.0.0.1",
      port = 4001,
      -- Path mapping: local source <-> pod source
      substitutePath = {
        { from = "${workspaceFolder}", to = "/" },
      },
    },
    -- {
    --   type = "go", -- Required by nvim-dap-go
    --   name = "Attach remote punda", -- The label that shows in your picker
    --   mode = "remote", -- Remote mode
    --   request = "attach", -- Attach request
    --   port = 4001, -- The port where dlv is listening
    --   host = "localhost", -- Change to remote IP if debugging a remote server
    --   substitutePath = {
    --     -- only for mac pottais
    --     -- { from = '/opt/homebrew/Cellar/go/1.23.1/libexec', to = '/usr/local/go'},
    --     { from = "${workspaceFolder}", to = "/home/root/go/bin/dlv" },
    --   },
    -- },
  },
  -- delve configurations
  delve = {
    -- the path to the executable dlv which will be used for debugging.
    -- by default, this is the "dlv" executable on your PATH.
    path = "dlv",
    -- time to wait for delve to initialize the debug session.
    -- default to 20 seconds
    initialize_timeout_sec = 20,
    -- a string that defines the port to start delve debugger.
    -- default to string "${port}" which instructs nvim-dap
    -- to start the process in a random available port.
    -- if you set a port in your debug configuration, its value will be
    -- assigned dynamically.
    -- port = "2346",
    -- additional args to pass to dlv
    args = {},
    -- the build flags that are passed to delve.
    -- defaults to empty string, but can be used to provide flags
    -- such as "-tags=unit" to make sure the test suite is
    -- compiled during debugging, for example.
    -- passing build flags using args is ineffective, as those are
    -- ignored by delve in dap mode.
    -- avaliable ui interactive function to prompt for arguments get_arguments
    build_flags = {},
    -- whether the dlv process to be created detached or not. there is
    -- an issue on delve versions < 1.24.0 for Windows where this needs to be
    -- set to false, otherwise the dlv server creation will fail.
    -- avaliable ui interactive function to prompt for build flags: get_build_flags
    detached = vim.fn.has "win32" == 0,
    -- the current working directory to run dlv from, if other than
    -- the current working directory.
    cwd = nil,
  },
  -- options related to running closest test
  tests = {
    -- enables verbosity when running the test.
    verbose = false,
  },
}
