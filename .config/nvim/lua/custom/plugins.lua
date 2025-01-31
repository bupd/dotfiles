local plugins = {
	{ "nvim-lua/plenary.nvim" },
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
				"astro",
				"gopls",
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
	{
		"nvzone/typr",
		dependencies = "nvzone/volt",
		opts = {},
		cmd = { "Typr", "TyprStats" },
	},
}
return plugins
