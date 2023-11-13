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

local function print_desc_apply_to_buf(buf, desc, apply, startl, nr)
    local line = string.format("%s. %-30s%s", nr, apply, desc)
    vim.api.nvim_buf_set_lines(
        buf,
        startl,
        -1,
        false,
        { line }
    )
end

local function open_tasks_win(buf)
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")
    local win_height = math.ceil(height * 0.4 - 4)
    local win_width = math.ceil(width * 0.7)

    -- starting position center
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)

    local win_opts = {
        style = "minimal",
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col
    }

    vim.api.nvim_open_win(buf, true, win_opts)

    -- window opts
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.wo.breakindent = true
    vim.wo.breakindentopt = 'shift:33' -- why 33 tho, we've got 30
end

function M.display_tasks()
    local buf = vim.api.nvim_create_buf(false, true)

    for i = 1, #M.tasks do
        local current_line = i - 1
        local desc = M.tasks[i][1]
        local apply = M.tasks[i][2]

        print_desc_apply_to_buf(buf, desc, apply, current_line, i)
    end

    local keymap_opts = {
        nowait = true, noremap = true, silent = true
    }

    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":bdelete<CR>", keymap_opts)

    -- some nice opts
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe') -- delete when closed

    -- this must be right before we open the window
    -- so we can programatically do stuff
    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    open_tasks_win(buf)
end

return M
