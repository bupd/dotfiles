local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require("null-ls")

local opts = {
  sources = {
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.formatting.prettier,
  },
  on_attach = function (client, bufnr)
    if client.supports_method("textDocument/formatting") then
      -- Correct the autocmd pattern
      vim.api.nvim_clear_autocmds("LspFormatting", bufnr)

      -- Register an autocmd for BufWritePre
      vim.api.nvim_exec([[
        autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
      ]], false)

    end
  end,
}

return opts

