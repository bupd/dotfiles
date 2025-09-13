return {
  "leoluz/nvim-dap-go",
  ft = { "go" },
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "mfussenegger/nvim-dap",
    "theHamsta/nvim-dap-virtual-text",
    -- "nvim-neotest/nvim-nio",
  },
  config = function()
    require("dap-go").setup()
  end,
  opts = function()
    return require "myconfig"
  end,
}
