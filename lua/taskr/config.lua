local M = {}

-- set default config
local config = {
    taskfile = "tasks",
    leader = "<leader>t",
    keymaps = {
        ["a"] = "TaskrAddFile",
        ["s"] = "TaskrSave",
        ["d"] = "TaskrDisplay",
    }
}

function M.setup(opts)
    M.config = vim.tbl_deep_extend("keep", opts or {}, config)
end

return M
