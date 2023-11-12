local M = {}

function M.setup(opts)
    require'taskr.config'.setup(opts)

    require'taskr.commands'.setup()
    require'taskr.keymaps'.setup()
end

return M
