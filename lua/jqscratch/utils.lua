local Path = require("plenary.path")

local M = {}

M.get_file_path = function(path)
  local sep = Path:new(path)._sep
  local new_sep = "_"
  local filename = path:gsub(sep, new_sep) .. ".txt"

  return filename
end

M.create_data_file = function(config)
  local data_dir = Path:new(config.data_dir)
  local cwd = vim.uv.cwd()
  if cwd == nil then
    return
  end

  local file_name = M.get_file_path(cwd)
  local file_path = data_dir:joinpath(file_name)

  if not file_path:is_file() then
    file_path:touch({ parents = true })
  end

  return file_path:normalize(cwd)
end

return M
