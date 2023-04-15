local M = {}

function M.eval()
  local file_path = vim.api.nvim_eval_statusline('%f', {}).str
  local modified = vim.api.nvim_eval_statusline('%M', {}).str  == '+' and '' or ''
  return string.format('%s %s %s', "%=", file_path, modified)
end

return M
