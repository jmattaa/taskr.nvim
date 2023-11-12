local tasks = require "taskr.tasks"
local config = require "taskr.config".config

local M = {}

function M.setup()
    for key, cmd in pairs(config.keymaps) do
        vim.keymap.set("n",
            config.leader .. key,
            function () vim.cmd(cmd) end
        )
    end
end

return M
