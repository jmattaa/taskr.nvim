function table.serialize(tbl)
    local str = "{"
    for k, v in pairs(tbl) do
        str = str .. "[" .. tostring(k) .. "]=" .. "\"" .. tostring(v) .. "\","
    end
    str = str .. "}"
    return str
end

function table.save_file(tbl, filename)
    local file = io.open(filename, "w")
    if file == nil then
        return
    end

    for i = 1, #tbl do
        local serializedTable = table.serialize(tbl[i])
        file:write(serializedTable, "\n") -- add newline after line
    end

    file:close()
end

-- Load all tables in a file. Tables are on one line each
function table.load_file(filename)
    local file = io.open(filename, "r")
    if file then
        local serializedTable = file:read("*a")
        file:close()
        local loadedTable = load("return " .. serializedTable)()
        return loadedTable
    else
        return nil
    end
end
