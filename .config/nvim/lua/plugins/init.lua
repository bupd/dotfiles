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
  { "rcarriga/nvim-notify", lazy = false },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensured_installed = {
        "bash",
        "comment",
        "css",
        "html",
        "javascript",
        "jsdoc",
        "jsonc",
        "lua",
        "markdown",
        "regex",
        "scss",
        "toml",
        "typescript",
        "yaml",
      },
    },
  },
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
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>tx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>tX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>tcs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>tcl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>txL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>txQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
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
