local plugins = {
	{ "nvim-lua/plenary.nvim" },
	{ "nvim-tree/nvim-web-devicons", lazy = true },
	{
		"nvchad/ui",
		config = function()
			require("nvchad")
		end,
	},
	{
		"nvchad/base46",
		lazy = true,
		build = function()
			require("base46").load_all_highlights()
		end,
	},
	-- "nvchad/volt", -- optional, needed for theme switcher
	-- or just use Telescope themes
	{ "ActivityWatch/aw-watcher-vim" },
	{ "christoomey/vim-tmux-navigator", lazy = false },
	{ "lewis6991/gitsigns.nvim", lazy = false },
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
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end,
	},
	-- null-ls replacement
	{
		"nvimtools/none-ls.nvim",
		event = "VeryLazy",
		opts = function()
			return require("custom.configs.null-ls")
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

	{ "williamboman/mason-lspconfig.nvim" },
	{ "rcarriga/nvim-notify", lazy = false },

	-- leetcode
	{
		"kawre/leetcode.nvim",
		build = ":TSUpdate html",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim", -- required by telescope
			"MunifTanjim/nui.nvim",
			-- optional
			"nvim-treesitter/nvim-treesitter",
			"rcarriga/nvim-notify",
			"nvim-tree/nvim-web-devicons",
		},
		lazy = false,
		-- event = "VeryLazy",
		opts = {
			---@type string
			arg = "leetcode.nvim",
			---@type lc.lang
			lang = "java",
			cn = { -- leetcode.cn
				enabled = false, ---@type boolean
				translator = true, ---@type boolean
				translate_problems = true, ---@type boolean
			},
			---@type lc.storage
			storage = {
				home = vim.fn.stdpath("data") .. "/leetcode",
				cache = vim.fn.stdpath("cache") .. "/leetcode",
			},
			---@type table<string, boolean>
			plugins = {
				non_standalone = false,
			},
			---@type boolean
			logging = true,
			injector = {}, ---@type table<lc.lang, lc.inject>
			cache = {
				update_interval = 60 * 60 * 24 * 7, ---@type integer 7 days
			},
			console = {
				open_on_runcode = true, ---@type boolean
				dir = "row", ---@type lc.direction
				size = { ---@type lc.size
					width = "90%",
					height = "75%",
				},
				result = {
					size = "60%", ---@type lc.size
				},
				testcase = {
					virt_text = true, ---@type boolean
					size = "40%", ---@type lc.size
				},
			},
			description = {
				position = "left", ---@type lc.position
				width = "40%", ---@type lc.size
				show_stats = true, ---@type boolean
			},
			hooks = {
				---@type fun()[]
				["enter"] = {},
				---@type fun(question: lc.ui.Question)[]
				["question_enter"] = {},
				---@type fun()[]
				["leave"] = {},
			},
			keys = {
				toggle = { "q" }, ---@type string|string[]
				confirm = { "<CR>" }, ---@type string|string[]
				reset_testcases = "r", ---@type string
				use_testcase = "U", ---@type string
				focus_testcases = "H", ---@type string
				focus_result = "L", ---@type string
			},
			---@type lc.highlights
			theme = {},
			---@type boolean
			image_support = false,
		},
	},

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
			vim.cmd([[silent! GoInstallDeps]])
		end,
	},
	{
		"ThePrimeagen/harpoon",
		event = "VeryLazy",
		config = function(_)
			require("custom.harpoon")
		end,
	},

	-- nvim dap
	{
		"mfussenegger/nvim-dap",
	},
	{
		"mfussenegger/nvim-jdtls",
	},
	{ "wakatime/vim-wakatime", lazy = false },
	-- typr testing thing
	{
		"nvzone/typr",
		dependencies = "nvzone/volt",
		opts = {},
		cmd = { "Typr", "TyprStats" },
	},
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
}
return plugins
