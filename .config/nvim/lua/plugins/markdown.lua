return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "norg", "rmd", "org" }, -- Load only for these file types
  config = function()
    require("render-markdown").setup {
      -- Optional configuration options here, e.g.
      -- headings = { ... },
      -- codeblocks = { ... },
    }
  end,
}
