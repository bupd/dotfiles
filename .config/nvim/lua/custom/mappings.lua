local M = {}
M.general = {
	n = {
		["<C-h>"] = { "<cmd> TmuxNavigateLeft<CR>", "window left" },
		["<C-l>"] = { "<cmd> TmuxNavigateRight<CR>", "window right" },
		["<C-j>"] = { "<cmd> TmuxNavigateDown<CR>", "window down" },

		-- Add toggle undotree
		["<leader>u"] = {
			"<cmd> UndotreeToggle <CR>",
			"Toggle undotree",
		},
	},
}
M.dap = {
	plugin = true,
	n = {
		["<leader>db"] = {
			"<cmd> DapToggleBreakpoint <CR>",
			"Add breakpoint at line",
		},
		["<leader>dr"] = {
			"<cmd> DapContinue <CR>",
			"Start or continue the debugger",
		},
	},
}

M.gitsigns = {
	plugin = true,

	n = {
		-- Navigation through hunks
		["]c"] = {
			function()
				if vim.wo.diff then
					return "]c"
				end
				vim.schedule(function()
					require("gitsigns").next_hunk()
				end)
				return "<Ignore>"
			end,
			"Jump to next hunk",
			opts = { expr = true },
		},

		["[c"] = {
			function()
				if vim.wo.diff then
					return "[c"
				end
				vim.schedule(function()
					require("gitsigns").prev_hunk()
				end)
				return "<Ignore>"
			end,
			"Jump to prev hunk",
			opts = { expr = true },
		},

		-- Actions
		["<leader>gH"] = {
			function()
				require("gitsigns").reset_hunk()
			end,
			"Reset hunk",
		},

		["<leader>gh"] = {
			function()
				require("gitsigns").preview_hunk()
			end,
			"Preview hunk",
		},

		["<leader>gu"] = {
			function()
				package.loaded.gitsigns.undo_stage_hunk()
			end,
			"Undo Stage Hunk",
		},

		["<leader>ga"] = {
			function()
				package.loaded.gitsigns.stage_hunk()
			end,
			"Stage Hunk",
		},

		["<leader>gS"] = {
			function()
				package.loaded.gitsigns.stage_buffer()
			end,
			"Stage Buffer",
		},

		["<leader>gU"] = {
			function()
				package.loaded.gitsigns.reset_buffer()
			end,
			"Reset Buffer",
		},

		["<leader>gb"] = {
			function()
				package.loaded.gitsigns.blame_line()
			end,
			"Blame line",
		},

		["<leader>gtd"] = {
			function()
				require("gitsigns").toggle_deleted()
			end,
			"Toggle deleted",
		},
	},
}

return M
