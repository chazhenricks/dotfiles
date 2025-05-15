local status_ok, oil = pcall(require, "oil")
if not status_ok then
  return
end

oil.setup {
  columns = {
    "icon",
  },
  view_options = {
    show_hidden = true,
  },
  default_file_explorer = false,
  -- use_default_keymaps = false,
}
