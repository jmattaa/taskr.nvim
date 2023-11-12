local M = {}

local config = require "taskr.config".config
local utils = require "taskr.utils"

M.tasks = utils.table.load_file(config.taskfile) or {}

function M.add_task(description, apply)
    if not description or not apply then
        vim.cmd [[
            echohl ErrorMsg
            echo "Taskr: Not enough args"
            echohl None
        ]]
        return
    end

    table.insert(M.tasks,
        { description, apply }
    )
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
    vim.cmd [[redraw]]
    if description == "" then return end

    M.add_task(description, filename)
end

function M.save_tasks()
    utils.table.save_file(M.tasks, config.taskfile)
    print("Taskr: Saved tasks")
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

local function print_desc_apply_to_buf(buf, desc, apply, startl)
    local line = string.format("%-40s\t%s", desc, apply)
    print_to_buf(buf, line, startl)
end

function M.display_tasks()
    local buf = vim.api.nvim_create_buf(false, true)

    for i = 1, #M.tasks do
        local current_line = i - 1
        local desc = M.tasks[i][1]
        local apply = M.tasks[i][2]

        print_desc_apply_to_buf(buf, desc, apply, current_line)
    end

    local keymap_opts = {
        nowait = true, noremap = true, silent = true
    }

    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":bdelete<CR>", keymap_opts)

    -- this must be right before we open the window
    -- so we can programatically do stuff
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_set_current_buf(buf)
end

return M
