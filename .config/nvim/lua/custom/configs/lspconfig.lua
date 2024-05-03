local configs = require("plugins.configs.lspconfig")
local on_attach = configs.on_attach
local capabilities = configs.capabilities

local lspconfig = require("lspconfig")
local servers = { "html", "clangd", "astro", "tsserver", "pyright", "tailwindcss"}

for _, lsp in ipairs(servers) do
 if lsp == "gopls" then
    lspconfig[lsp].setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        gopls = {
          usePlaceholders = true,  -- Set placeholders to true for gopls
          analyses = {
            unusedParams = true,
          },
        }
      }
    }
  elseif lsp == "tsserver" then
    lspconfig[lsp].setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        tsserver = {
          suggest = {
            completeFunctionCalls = true,
          }
        }
      }
    }
  else
    lspconfig[lsp].setup {
      on_attach = on_attach,
      capabilities = capabilities,
    }
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
