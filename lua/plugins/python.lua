-- PyCharm-like Python + uv experience
-- Prerequisites: uv (https://docs.astral.sh/uv), fd

---@param cmd string[]
---@param on_ok fun(out: vim.SystemCompleted)
local function uv_run(cmd, on_ok)
    local full = vim.list_extend({ 'uv' }, cmd)
    vim.notify(
        'Running: ' .. table.concat(full, ' '),
        vim.log.levels.INFO,
        { title = 'uv' }
    )
    vim.system(full, { text = true }, function(out)
        vim.schedule(function()
            if out.code ~= 0 then
                vim.notify(
                    vim.trim(out.stderr ~= '' and out.stderr or out.stdout),
                    vim.log.levels.ERROR,
                    { title = 'uv' }
                )
            else
                on_ok(out)
            end
        end)
    end)
end

--- PyCharm-style: pick a Python version → uv creates .venv with it
local function select_python_and_create_venv()
    uv_run({ 'python', 'list' }, function(out)
        local versions = {} ---@type {version: string, path: string, installed: boolean}[]
        for line in out.stdout:gmatch('[^\r\n]+') do
            -- e.g. "cpython-3.12.7-linux-x86_64-gnu    /home/user/.local/share/uv/python/cpython-3.12.7/bin/python3"
            --   or "cpython-3.11.10-linux-x86_64-gnu    <download available>"
            local id, rest = line:match('^(%S+)%s+(.+)$')
            if id then
                local ver = id:match('cpython%-([%d%.]+)') or id
                local installed = not rest:match('<download available>')
                table.insert(
                    versions,
                    { version = ver, path = rest, installed = installed }
                )
            end
        end

        if #versions == 0 then
            vim.notify(
                'No Python versions found. Run `uv python list` to check.',
                vim.log.levels.WARN,
                { title = 'uv' }
            )
            return
        end

        vim.ui.select(versions, {
            prompt = ' Select Python version (uv will download if needed):',
            format_item = function(item)
                local marker = item.installed and '● installed'
                    or '○ download'
                return (' Python %s  [%s]'):format(item.version, marker)
            end,
        }, function(choice)
            if not choice then
                return
            end
            uv_run({ 'venv', '--python', choice.version }, function()
                vim.notify(
                    ('✓ Venv created with Python %s\nRestarting LSP…'):format(
                        choice.version
                    ),
                    vim.log.levels.INFO,
                    { title = 'uv' }
                )
                vim.cmd('LspRestart')
            end)
        end)
    end)
end

--- Prompt-based uv command helper
---@param subcmd string[]
---@param msg string
---@param prompt? string
local function uv_action(subcmd, msg, prompt)
    return function()
        local function exec(input)
            local cmd = vim.deepcopy(subcmd)
            if input then
                table.insert(cmd, input)
            end
            uv_run(cmd, function()
                vim.notify(
                    msg:format(input or ''),
                    vim.log.levels.INFO,
                    { title = 'uv' }
                )
                if
                    subcmd[1] == 'sync'
                    or subcmd[1] == 'add'
                    or subcmd[1] == 'remove'
                then
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
    -- ── venv-selector: discover uv venvs ──────────────────────────────
    {
        'linux-cultist/venv-selector.nvim',
        opts = {
            settings = {
                search = {
                    project_venv = {
                        command = (vim.fn.has('win32') == 1)
                                and 'fd python.exe$ .venv --full-path --color never -IH -a'
                            or 'fd python$ .venv --full-path --color never -IH -a',
                    },
                },
                options = { notify_user_on_venv_activation = true },
            },
        },
    },

    -- ── Which-Key group ────────────────────────────────────────────────
    {
        'folke/which-key.nvim',
        optional = true,
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

  -- ── uv workflow keymaps ────────────────────────────────────────────
  -- stylua: ignore
  {
    name = "uv-workflow",
    dir = vim.fn.stdpath("config"),
    keys = {
      -- ★ The PyCharm-style version picker
      { "<leader>cUp", select_python_and_create_venv,                                          desc = "Select Python & Create Venv", ft = "python" },
      -- Project
      { "<leader>cUi", uv_action({ "init" },            "Project initialized ✓"),              desc = "Init Project",   ft = "python" },
      { "<leader>cUc", uv_action({ "venv" },             "Venv created ✓"),                    desc = "Create Venv",    ft = "python" },
      -- Dependencies
      { "<leader>cUa", uv_action({ "add" },              "Added: %s ✓",          "Package: "), desc = "Add Package",    ft = "python" },
      { "<leader>cUr", uv_action({ "remove" },           "Removed: %s ✓",        "Package: "), desc = "Remove Package", ft = "python" },
      { "<leader>cUs", uv_action({ "sync" },             "Dependencies synced ✓"),             desc = "Sync Deps",      ft = "python" },
      { "<leader>cUl", uv_action({ "lock" },             "Lockfile updated ✓"),                desc = "Update Lock",    ft = "python" },
    },
  },
}
