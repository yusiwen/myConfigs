local present, treesitter_context = pcall(require, "treesitter-context")

if not present then
  return
end

treesitter_context.setup({
  enable = true,
  max_lines = 0,
  trim_scope = 'outer',
  patterns = {
    default = {
      'class',
      'function',
      'method',
      'for',
      'while',
      'if',
      'switch',
      'case',
    },
  },
})
