local present, better_escape = pcall(require, "better_escape")

if not present then
  return
end

better_escape.setup {
}
