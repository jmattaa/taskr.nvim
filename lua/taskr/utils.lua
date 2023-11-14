local M = { table = {}, string = {}, taskwin = {} }

M.taskwin.display_lhs_size = 40

function M.table.serialize(tbl)
    local str = "{"
    for k, v in pairs(tbl) do
        local val = v
        if type(val) == "table" then
            val = M.table.serialize(v)
        else
            val = "\"" .. tostring(v) .. "\""
        end

        str = str .. "[" .. tostring(k) .. "]=" .. val .. ","
    end
    str = str .. "}"
    return str
end

function M.table.save_file(tbl, filename)
    local file = io.open(filename, "w")
    if file == nil then
        return
    end

    for i = 1, #tbl do
        local serializedTable = M.table.serialize(tbl[i])
        file:write(serializedTable, "\n") -- add newline after line
    end

    file:close()
end

-- Load all tables in a file. Tables are on one line each
function M.table.load_file(filename)
    local file = io.open(filename, "r")
    if file then
        local tables = {}
        for line in file:lines() do
            local loadedTable = load("return " .. line)()
            table.insert(tables, loadedTable)
        end
        file:close()
        return tables
    else
        return nil
    end
end

function M.string.truncate(str, max)
    if #str > max then
        return string.sub(str, 1, max) .. "..."
    else
        return str
    end
end

function M.taskwin.print_desc_apply_to_buf(buf, desc, apply, startl, nr)
    local maxChars = M.taskwin.display_lhs_size - 6

    local lhs = ""

    if apply[2] ~= nil then
        local linenum = apply[2][1] -- cursor col is in apply[2][2]
        lhs = apply[1] .. ":" .. linenum
    else
        lhs = apply[1]
    end

    lhs = M.string.truncate(lhs, maxChars)

    local line = string.format(
        "%s. %-" .. M.taskwin.display_lhs_size .. "s%s",
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

function M.taskwin.open_tasks_win(buf)
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")
    local win_height = math.ceil(height * 0.4 - 4)
    local win_width = math.ceil(width * 0.5)

    -- starting position center
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)

    local border_buf = vim.api.nvim_create_buf(false, true) -- create the border
    -- add border
    local border_opts = {
        style = "minimal",
        relative = "editor",
        width = win_width + 2,
        height = win_height + 2,
        row = row - 1,
        col = col - 1
    }
    local border_lines = { '╭' .. string.rep('─', win_width) .. '╮' }
    local middle_line = '│' .. string.rep(' ', win_width) .. '│'
    -- go until before searchbar height
    for i = 1, win_height do
        table.insert(border_lines, middle_line)
    end
    table.insert(border_lines, '╰' .. string.rep('─', win_width) .. '╯')
    vim.api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

    -- show the border win
    vim.api.nvim_open_win(border_buf, true, border_opts)




    -- main win
    local win_opts = {
        style = "minimal",
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col
    }

    vim.api.nvim_open_win(buf, true, win_opts)
    -- wipeout border when we close this 
    vim.api.nvim_command(
        'au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf
    )

    -- window opts
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.wo.breakindent = true

    -- why +3 tho, idk but it works
    vim.wo.breakindentopt = 'shift:' .. M.taskwin.display_lhs_size + 3
end

return M
