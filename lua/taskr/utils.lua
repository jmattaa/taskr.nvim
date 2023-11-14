local M = { table = {}, string = {} }

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

return M
