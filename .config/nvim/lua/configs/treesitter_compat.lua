local M = {}

local html_script_type_languages = {
  importmap = "json",
  module = "javascript",
  ["application/ecmascript"] = "javascript",
  ["text/ecmascript"] = "javascript",
}

local markdown_language_aliases = {
  ex = "elixir",
  pl = "perl",
  sh = "bash",
  ts = "typescript",
  uxn = "uxntal",
}

local function first_node(match, capture_id)
  local capture = match[capture_id]
  if type(capture) == "table" then
    return capture[1]
  end
  return capture
end

local function parser_from_markdown_info_string(alias)
  local filetype = vim.filetype.match { filename = "a." .. alias }
  return filetype or markdown_language_aliases[alias] or alias
end

function M.setup()
  local query = vim.treesitter.query

  query.add_directive("set-lang-from-mimetype!", function(match, _, source, pred, metadata)
    local node = first_node(match, pred[2])
    if not node then
      return
    end

    local type_attr_value = vim.treesitter.get_node_text(node, source)
    local configured = html_script_type_languages[type_attr_value]
    if configured then
      metadata["injection.language"] = configured
      return
    end

    local parts = vim.split(type_attr_value, "/", {})
    metadata["injection.language"] = parts[#parts]
  end, { force = true })

  query.add_directive("set-lang-from-info-string!", function(match, _, source, pred, metadata)
    local node = first_node(match, pred[2])
    if not node then
      return
    end

    local alias = vim.treesitter.get_node_text(node, source):lower()
    metadata["injection.language"] = parser_from_markdown_info_string(alias)
  end, { force = true })
end

return M
