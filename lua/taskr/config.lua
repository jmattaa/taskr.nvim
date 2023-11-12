local utils = require 'taskr.utils'
local M = {}

-- set default config
local config = {
    taskfile = "tasks",
    leader = "<leader>t",
    keymaps = {
        ["a"] = "add_current_file",
        ["s"] = "save_tasks",
    }
}

function M.setup(opts)
    M.config = vim.tbl_deep_extend("keep", opts or {}, config)
end

return M
