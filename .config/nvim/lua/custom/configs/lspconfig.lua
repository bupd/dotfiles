local configs = require("plugins.configs.lspconfig")
local on_attach = configs.on_attach
local capabilities = configs.capabilities

local lspconfig = require("lspconfig")
local servers = {
	"html",
	"clangd",
	"astro",
	"tsserver",
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
