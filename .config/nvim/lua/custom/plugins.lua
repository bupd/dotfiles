local plugins = {
  { "nvim-lua/plenary.nvim" },
  {"ActivityWatch/aw-watcher-vim"},
  {'christoomey/vim-tmux-navigator',
    lazy=false, },
  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
  "mbbill/undotree",
  dependencies = "nvim-lua/plenary.nvim",
  -- config = true,
  keys = { -- load the plugin only when using it's keybinding:
    { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
  },
   config=function ()
      require('undotree').setup()
    end

  },
  {
    "windwp/nvim-ts-autotag",
    ft={
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "html",
    },
    config=function ()
     require("nvim-ts-autotag").setup()
    end
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
    "williamboman/mason.nvim",
    "mfussenegger/nvim-dap",
    },
      opts = {
        handlers = {},
    },
  },
  {
    "mfussenegger/nvim-dap",
    config = function (_, _)
      require("core.utils").load_mappings("dap")
    end
  },
  {
    "mfussenegger/nvim-dap-python",
    ft="python",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function (_, opts)
      local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(path)
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function ()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    event = "VeryLazy",
    opts = function ()
      return require "custom.configs.null-ls"
    end,
  },
  -- {
  --   "jose-elias-alvarez/null-ls.nvim",
  --   event = "VeryLazy",
  --   opts = function ()
  --     return require "custom.configs.null-ls"
  --   end,
  -- },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "typescript-language-server",
        "tailwindcss-language-server",
        "eslint-lsp",
        "pyright",
        "mypy",
        "ruff",
        "black",
        "debugpy",
      }
    }
  },
  {"williamboman/mason-lspconfig.nvim"},
  {
    "ThePrimeagen/harpoon",
    event = "VeryLazy",
    config = function (_)
      require "custom.harpoon"
    end
  }
}
return plugins
