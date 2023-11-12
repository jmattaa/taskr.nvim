local tasks = require "taskr.tasks"
local config = require "taskr.config".config

local M = {}

function M.add_current_file()
    tasks.add_current_file()
end

function M.save_tasks()
    tasks.save_tasks()
end

function M.setup()
    for key, cmd in pairs(config.keymaps) do
        vim.keymap.set("n",
            config.leader .. key,
            function () M[cmd]() end
        )
    end
end

return M
