return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",

    config = function()
      local parsers = {
        "bash",
        "c",
        "comment",
        "css",
        "go",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "regex",
        "rust",
        "scss",
        "toml",
        "typescript",
        "vimdoc",
        "yaml",
      }

      require("nvim-treesitter").setup {}
      require("nvim-treesitter").install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "c",
          "css",
          "go",
          "javascript",
          "javascriptreact",
          "jsonc",
          "lua",
          "markdown",
          "regex",
          "rust",
          "scss",
          "sh",
          "toml",
          "typescript",
          "typescriptreact",
          "vimdoc",
          "yaml",
        },
        callback = function(args)
          local max_filesize = 100 * 1024
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
          if ok and stats and stats.size > max_filesize then
            vim.notify(
              "File larger than 100KB; Tree-sitter disabled for performance",
              vim.log.levels.WARN,
              { title = "Tree-sitter" }
            )
            return
          end

          local filetype = vim.bo[args.buf].filetype
          local language = vim.treesitter.language.get_lang(filetype) or filetype
          if pcall(vim.treesitter.start, args.buf, language) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    after = "nvim-treesitter",
    config = function()
      require("treesitter-context").setup {
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        multiwindow = false, -- Enable multiwindow support.
        max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to show for a single context
        trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20, -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
      }
    end,
  },
}
