return {
  "jay-babu/mason-nvim-dap.nvim",
  dependencies = {
    "williamboman/mason.nvim",      -- mason
    "mfussenegger/nvim-dap",        -- dap itself (usually required)
  },
  cmd = { "DapInstall", "DapUninstall" },
  opts = {
    -- Automatically install configured debuggers
    automatic_installation = true,

    -- Optional handlers for extra setup
    handlers = {},

    -- Ensure delve (Go debugger) is installed
    ensure_installed = { "delve" },
  },
  config = function(_, opts)
    require("mason-nvim-dap").setup(opts) -- setup with opts
  end,
}
