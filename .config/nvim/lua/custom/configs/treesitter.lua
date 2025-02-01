local configs = require("nvim-treesitter.configs")

configs.setup({
	ensure_installed = {
		"c",
		"lua",
		"vim",
		"vimdoc",
		"query",
		"typescript",
		"css",
		"go",
		"python",
		"javascript",
		"html",
	},
	sync_install = false,
	highlight = { enable = true },
	indent = { enable = true },
})
