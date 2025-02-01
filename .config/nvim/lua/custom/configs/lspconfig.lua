local configs = require("plugins.configs.lspconfig")
local on_attach = configs.on_attach
local capabilities = configs.capabilities

local lspconfig = require("lspconfig")

-- local nvlsp = require "nvchad.configs.lspconfig"
-- local on_attach = nvlsp.on_attach
-- local capabilities = nvlsp.capabilities
--
-- nvlsp.defaults() -- loads nvchad's defaults

local servers = {
	"html",
	"clangd",
	"astro",
	"ts_ls",
	"pyright",
	"gopls",
	"angularls",
	"tailwindcss",
	"bashls",
	"lua_ls",
	"docker_compose_language_service",
	"dockerls",
	"yamlls",
}

for _, lsp in ipairs(servers) do
	if lsp == "gopls" then
		lspconfig[lsp].setup({
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				gopls = {
					usePlaceholders = true, -- Set placeholders to true for gopls
					analyses = {
						unusedParams = true,
					},
				},
			},
		})
	elseif lsp == "tsserver" then
		lspconfig[lsp].setup({
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				tsserver = {
					suggest = {
						completeFunctionCalls = true,
					},
				},
			},
		})
	elseif lsp == "docker_compose_language_service" then
		lspconfig[lsp].setup({
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = {
				"yml.docker-compose",
				"yaml.docker-compose",
			},
		})
	elseif lsp == "yamlls" then
		lspconfig[lsp].setup({
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				yaml = {
					schemas = {
						["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
						["../path/relative/to/file.yml"] = "/.github/workflows/*",
						["/path/from/root/of/project"] = "/.github/workflows/*",
					},
				},
			},
		})
	elseif lsp == "lua_ls" then
		lspconfig[lsp].setup({
			on_attach = on_attach,
			capabilities = capabilities,
			on_init = function(client)
				local path = client.workspace_folders[1].name
				if vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc") then
					return
				end
				client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
					runtime = {
						-- Tell the language server which version of Lua you're using
						-- (most likely LuaJIT in the case of Neovim)
						version = "LuaJIT",
					},
					-- Make the server aware of Neovim runtime files
					workspace = {
						checkThirdParty = false,
						library = {
							vim.env.VIMRUNTIME,
							-- Depending on the usage, you might want to add additional paths here.
							-- "${3rd}/luv/library"
							-- "${3rd}/busted/library",
						},
						-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
						-- library = vim.api.nvim_get_runtime_file("", true)
					},
				})
			end,
			settings = {
				Lua = {},
			},
		})
	else
		lspconfig[lsp].setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
	end
end

-- lspconfig.tsserver.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   init_options = {
--     prefrences = {
--       disableSuggestions = false,
--     }
--   }
-- }
