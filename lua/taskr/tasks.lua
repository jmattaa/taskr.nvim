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

    local description = vim.fn.input("Task description: ")
    if description == "" then return end

    M.add_task(description, filename)
end

function M.save_tasks()
    utils.table.save_file(M.tasks, config.taskfile)
end

-- didn't take this from quickmark.nvim
-- startl starting line index
-- endl ending line index -1 for last line
-- u see i read docs
local function print_to_buf(buf, str, startl)
    vim.api.nvim_buf_set_lines(
        buf,
        startl,
        -1,
        false,
        { str }
    )
end

function M.display_tasks()
    local buf = vim.api.nvim_create_buf(false, true)

    print_to_buf(buf, "Hello", 0)
    print_to_buf(buf, "Hello", 1)
    print_to_buf(buf, "Hello", 2)
    print_to_buf(buf, "Taskr nvim stuff", 3)

    local keymap_opts = {
        nowait = true, noremap = true, silent = true
    }

    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':bdelete<CR>', keymap_opts)

    -- this must be right before we open the window
    -- so we can programatically do stuff
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_set_current_buf(buf)
end

return M
