local M = {}

local config = require "taskr.config".config
local utils = require "taskr.utils"

local _tasks = utils.table.load_file(config.taskfile) or {}

function M.add_task(description, apply)
    if not description or not apply then
        vim.cmd [[
            echohl ErrorMsg
            echo "Taskr: Not enough args"
            echohl None
        ]]
        return
    end

    table.insert(_tasks,
        { description, apply }
    )
    M.tasks = _tasks
end

function M.add_current_file()
    local filename = vim.fn.expand('%:~:.')

    if filename == "" then
        vim.cmd [[
            echohl ErrorMsg
            echo "Taskr: Cannot add empty filename"
            echohl None
        ]]
        return
    end

    local description = vim.fn.input("Task description: ", "")

    M.add_task(description, filename)
end

function M.save_tasks()
    utils.table.save_file(M.tasks, config.taskfile)
end

return M
