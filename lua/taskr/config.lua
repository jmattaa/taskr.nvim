local M = {}

-- set default config
M.config = {
    taskfile = ".tasks",
    leader = "<leader>t",
}

function M.init(opts)
    M.config = vim.tbl_deep_extend("keep", opts or {}, M.config)
end

return M
