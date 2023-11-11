local config = require "taskr.config"

local M = {}

function M.setup(opts)
    config.init(opts)
end

return M
