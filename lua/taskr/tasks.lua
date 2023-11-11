local M = {}

local config = require("taskr").config

local tasks = table.load_file(config.taskfiles) or {}

function M.add_task(taskname, description, apply)
    print("from add task " .. config)
end

M.tasks = tasks

return M
