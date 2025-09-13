return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  { "christoomey/vim-tmux-navigator", lazy = false },

  -- file managing , picker etc
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = function()
      return require "configs.nvimtree"
    end,
  },

  -- gitsigns
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
  },
  {
    "mbbill/undotree",
    lazy = false,
  },
  {
    "windwp/nvim-ts-autotag",
    ft = {
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "html",
    },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  -- astrojs plugin
  { "wuelnerdotexe/vim-astro" },

  -- mason ensure_installed
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "angular-language-server@16.2.0",
        "typescript-language-server",
        "tailwindcss-language-server",
        "astro-language-server",
        "bash-language-server",
        "lua-language-server",
        "dockerfile-language-server",
        "docker-compose-language-service",
        "gopls",
        "goimports",
        "stylua",
        "isort",
        "yamlfix",
        "yaml-language-server",
        "prettierd",
        "gofumpt",
        "golines",
        "gospel",
        "grammarly-languageserver",
        "eslint-lsp",
        "pyright",
        "mypy",
        "ruff",
        "black",
        "debugpy",
      },
    },
  },
  -- { "williamboman/mason-lspconfig.nvim" },
  -- nvim notify
  -- { "rcarriga/nvim-notify", lazy = false },
  {'L3MON4D3/LuaSnip', lazy = false},
  -- gopher for new things
  {
    "olexsmir/gopher.nvim",
    requires = { -- dependencies
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },

    ft = "go",
    config = function(_, opts)
      require("gopher").setup(opts)
    end,
    build = function()
      vim.cmd [[silent! GoInstallDeps]]
    end,
  },
  -- harpoon
  {
    "ThePrimeagen/harpoon",
    event = "VeryLazy",
    config = function(_)
      require "configs.harpoon"
    end,
  },
  { "wakatime/vim-wakatime", lazy = false },
  -- vim fugitive
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
  },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
