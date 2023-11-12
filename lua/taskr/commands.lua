local M = {}

local commands = {
    TaskrAdd = {
        run = "add_task",
        mod = "taskr.tasks",
        args = {
            nargs = '*'
        },
    },
    TaskrAddFile = {
        run = "add_current_file",
        mod = "taskr.tasks",
        args = {
            nargs = 0
        },
    },
    TaskrSave = {
        run = "save_tasks",
        mod = "taskr.tasks",
        args = {
            nargs = 0
        },
    },
    TaskrDisplay = {
        run = "display_tasks",
        mod = "taskr.tasks",
        args = {
            nargs = 0,
        },
    },
}

function M.setup()
    for command, cmd_def in pairs(commands) do
        vim.api.nvim_create_user_command(
            command,
            function(opts)
                vim.cmd(
                    string.format(
                        "lua require'%s'.%s(%s)",
                        cmd_def.mod,
                        cmd_def.run,
                        string.gsub(opts.args, " ", ",")
                    )
                )
            end,
            cmd_def.args
        )
    end
end

return M
