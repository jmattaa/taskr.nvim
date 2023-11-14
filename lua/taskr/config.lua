local M = {}

-- set default config
local config = {
    taskfile = "tasks",
    leader = "<leader>t",
    autosave = true, -- save after add 
    keymaps = {
        ["a"] = "TaskrAddLine",
        ["f"] = "TaskrAddFile",
        ["s"] = "TaskrSave",
        ["d"] = "TaskrDisplay",
    }
}

function M.setup(opts)
    M.config = vim.tbl_deep_extend("keep", opts or {}, config)
end

return M
