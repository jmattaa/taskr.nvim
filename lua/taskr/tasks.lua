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

    if config.autosave == true then
        M.save_tasks()
    end
end

function M.add_current_line()
    local filename = vim.fn.expand('%:~:.')
    local cursorpos = vim.api.nvim_win_get_cursor(0)

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

    M.add_task(description, { filename, cursorpos })
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

    M.add_task(description, { filename })
end

function M.save_tasks()
    utils.table.save_file(M.tasks, config.taskfile)
    print("Taskr: Saved tasks")
end

-- open the task under cursor in task window
function M.open_current_task()
    local idx = vim.api.nvim_win_get_cursor(0)[1]
    local task = M.tasks[idx]
    local filename = task[2][1]

    vim.cmd("bdelete")
    vim.cmd("e " .. filename)

    -- set cursor position
    if task[2][2] ~= nil then
        local curpos = task[2][2]
        local curRow = tonumber(curpos[1])
        local curCol = tonumber(curpos[2])
        vim.api.nvim_win_set_cursor(0, { curRow, curCol })
    end
end

local function set_display_tasks_keymaps(buf)
    local keymap_opts = {
        nowait = true, noremap = true, silent = true
    }

    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":bdelete<CR>", keymap_opts)
    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>",
        ":TaskrOpenCurrentTask<CR>", keymap_opts)
end

function M.display_tasks()
    local buf = vim.api.nvim_create_buf(false, true)

    for i = 1, #M.tasks do
        local current_line = i - 1
        local desc = M.tasks[i][1]
        local apply = M.tasks[i][2]

        utils.taskwin.print_desc_apply_to_buf(buf, desc, apply, current_line, i)

        -- flip highlight at every other line so we clearly see stuff
        local hlgroup
        if i % 2 == 0 then
            hlgroup = "TaskrTask1"
        else
            hlgroup = "TaskrTask2"
        end

        vim.api.nvim_buf_add_highlight(
            buf,
            -1,
            hlgroup,
            current_line,
            0, -1
        )
    end

    set_display_tasks_keymaps(buf)

    -- some nice opts
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe') -- delete when closed

    -- this must be right before we open the window
    -- so we can programatically do stuff
    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    utils.taskwin.open_tasks_win(buf)
end

return M
