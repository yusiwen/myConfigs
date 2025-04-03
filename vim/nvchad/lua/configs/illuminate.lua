local present, illuminate = pcall(require, "illuminate")

if not present then
  return
end

illuminate.configure {
  providers = {
    "lsp",
    "treesitter",
    "regex",
  },
  delay = 100,
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
  under_cursor = false,
}

