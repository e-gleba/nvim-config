---@type table<string, true>
local LSP_TRIGGERS = { sync = true, add = true, remove = true }

---@param msg string
---@param level? integer
local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = 'uv' })
end

---@param cmd string[]
---@param on_ok fun(out: vim.SystemCompleted)
local function uv(cmd, on_ok)
    vim.system({ 'uv', unpack(cmd) }, { text = true }, function(out)
        vim.schedule(function()
            if out.code ~= 0 then
                notify(
                    vim.trim(out.stderr ~= '' and out.stderr or out.stdout),
                    vim.log.levels.ERROR
                )
            else
                on_ok(out)
            end
        end)
    end)
end

local function select_python()
    uv({ 'python', 'list' }, function(out)
        ---@type { version: string, installed: boolean }[]
        local versions = vim.iter(
            vim.split(out.stdout, '\n', { trimempty = true })
        )
            :map(function(line)
                local id, rest = line:match('^(%S+)%s+(.+)$')
                if not id then
                    return
                end
                return {
                    version = id:match('cpython%-([%d%.]+)') or id,
                    installed = not rest:match('<download available>'),
                }
            end)
            :totable()

        if #versions == 0 then
            return notify(
                'No Python versions found — run `uv python list`',
                vim.log.levels.WARN
            )
        end

        vim.ui.select(versions, {
            prompt = 'Select Python version:',
            ---@param v { version: string, installed: boolean }
            format_item = function(v)
                return ('%s %s  [%s]'):format(
                    v.installed and '●' or '○',
                    v.version,
                    v.installed and 'installed' or 'download'
                )
            end,
        }, function(choice)
            if not choice then
                return
            end
            uv({ 'venv', '--python', choice.version }, function()
                notify(('Venv created — Python %s'):format(choice.version))
                vim.cmd('LspRestart')
            end)
        end)
    end)
end

---@param subcmd string[]
---@param msg string
---@param prompt? string
---@return fun()
local function action(subcmd, msg, prompt)
    return function()
        ---@param input? string
        local function exec(input)
            local cmd = vim.deepcopy(subcmd)
            if input then
                cmd[#cmd + 1] = input
            end
            uv(cmd, function()
                notify(msg:format(input or ''))
                if LSP_TRIGGERS[subcmd[1]] then
                    vim.cmd('LspRestart')
                end
            end)
        end
        if prompt then
            vim.ui.input({ prompt = prompt }, function(input)
                if input and input ~= '' then
                    exec(input)
                end
            end)
        else
            exec()
        end
    end
end

---@type LazyPluginSpec[]
return {
    {
        'linux-cultist/venv-selector.nvim',
        ft = 'python',
        cmd = 'VenvSelect',
        opts = {
            settings = {
                search = {
                    project_venv = {
                        command = jit.os == 'Windows'
                                and 'fd python.exe$ .venv --full-path --color never -IH -a'
                            or 'fd python$ .venv --full-path --color never -IH -a',
                    },
                },
                options = { notify_user_on_venv_activation = true },
            },
        },
    },
    {
        'folke/which-key.nvim',
        opts = {
            spec = {
                {
                    '<leader>cU',
                    group = 'uv (Python)',
                    icon = { icon = '', color = 'yellow' },
                },
            },
        },
    },
    {
        name = 'uv-workflow',
        dir = vim.fn.stdpath('config'),
        keys = {
            {
                '<leader>cUp',
                select_python,
                desc = 'UV: Python → Venv',
                ft = 'python',
            },
            {
                '<leader>cUi',
                action({ 'init' }, 'Project initialized'),
                desc = 'UV: Init',
                ft = 'python',
            },
            {
                '<leader>cUc',
                action({ 'venv' }, 'Venv created'),
                desc = 'UV: Create Venv',
                ft = 'python',
            },
            {
                '<leader>cUa',
                action({ 'add' }, 'Added %s', 'Package: '),
                desc = 'UV: Add Package',
                ft = 'python',
            },
            {
                '<leader>cUr',
                action({ 'remove' }, 'Removed %s', 'Package: '),
                desc = 'UV: Remove Package',
                ft = 'python',
            },
            {
                '<leader>cUs',
                action({ 'sync' }, 'Synced'),
                desc = 'UV: Sync',
                ft = 'python',
            },
            {
                '<leader>cUl',
                action({ 'lock' }, 'Lockfile updated'),
                desc = 'UV: Lock',
                ft = 'python',
            },
            {
                '<leader>cUv',
                '<cmd>VenvSelect<cr>',
                desc = 'UV: Select Venv',
                ft = 'python',
            },
        },
    },
}
