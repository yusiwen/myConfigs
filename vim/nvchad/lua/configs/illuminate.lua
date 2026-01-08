local present, illuminate = pcall(require, "illuminate")

if not present then
  return
end

illuminate.configure({
  delay = 200,
  under_cursor = true,
  large_file_cutoff = 2000,
  large_file_overrides = {
    providers = { "lsp" },
  },
  providers = {
    "lsp",
    "treesitter",
    "regex",
  },
  filetypes_denylist = {
    "alpha",
    "dashboard",
    "DoomInfo",
    "fugitive",
    "help",
    "norg",
    "NvimTree",
    "Outline",
    "packer",
    "toggleterm",
  },
})

