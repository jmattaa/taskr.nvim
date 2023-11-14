local M = {}

local config = require "taskr.config".config
local utils = require "taskr.utils"

local display_lhs_size = 40

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

local function print_desc_apply_to_buf(buf, desc, apply, startl, nr)
    local maxChars = display_lhs_size - 6

    local lhs = ""

    if apply[2] ~= nil then
        local linenum = apply[2][1] -- cursor col is in apply[2][2]
        lhs = apply[1] .. ":" .. linenum
    else
        lhs = apply[1]
    end

    lhs = utils.string.truncate(lhs, maxChars)

    local line = string.format(
        "%s. %-" .. display_lhs_size .. "s%s",
        nr, lhs, desc
    )

    vim.api.nvim_buf_set_lines(
        buf,
        startl,
        startl + 1,
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

    -- why +3 tho, idk but it works
    vim.wo.breakindentopt = 'shift:' .. display_lhs_size + 3
end

function M.display_tasks()
    local buf = vim.api.nvim_create_buf(false, true)

    for i = 1, #M.tasks do
        local current_line = i - 1
        local desc = M.tasks[i][1]
        local apply = M.tasks[i][2]

        print_desc_apply_to_buf(buf, desc, apply, current_line, i)

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
