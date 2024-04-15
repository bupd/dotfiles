local plugins = {
  { "nvim-lua/plenary.nvim" },
  {"ActivityWatch/aw-watcher-vim"},
  {'christoomey/vim-tmux-navigator',
    lazy=false, },
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
