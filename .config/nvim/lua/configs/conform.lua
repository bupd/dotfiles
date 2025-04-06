local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettierd" },
    html = { "prettierd" },
    -- Conform will run multiple formatters sequentially
    go = { "goimports", "gofmt" },
    -- Conform will run the first available formatter
    javascript = { "prettierd"},
    typescript = { "prettierd"},
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
