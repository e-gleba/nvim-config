-- lua/plugins/asmview.lua

---@class AsmView
---@field buf integer?
---@field win integer?
---@field augroup integer?
local M = { buf = nil, win = nil, augroup = nil }

---@return string?
local function get_build_dir()
    local ok, cmake = pcall(require, 'cmake-tools')
    if ok and cmake.get_build_directory then
        local dir = cmake.get_build_directory()
        local path = type(dir) == 'string' and dir or (dir and tostring(dir))
        if
            path
            and vim.uv.fs_stat(vim.fs.joinpath(path, 'compile_commands.json'))
        then
            return path
        end
    end
    local root = vim.fs.root(0, { 'CMakeLists.txt' })
    if not root then
        return
    end
    if vim.uv.fs_stat(vim.fs.joinpath(root, 'compile_commands.json')) then
        return root
    end
    for _, dir in ipairs({
        'build',
        'cmake-build-debug',
        'cmake-build-release',
        'out/build',
    }) do
        local p = vim.fs.joinpath(root, dir)
        if vim.uv.fs_stat(vim.fs.joinpath(p, 'compile_commands.json')) then
            return p
        end
    end
end

---@param build_dir string
---@return { compiler: string, args: string[] }?
local function parse_entry(build_dir)
    local db_path = vim.fs.joinpath(build_dir, 'compile_commands.json')
    local ok, db =
        pcall(vim.json.decode, table.concat(vim.fn.readfile(db_path), '\n'))
    if not ok or type(db) ~= 'table' then
        return
    end

    local target = vim.fs.basename(vim.api.nvim_buf_get_name(0))
    if target == '' then
        return
    end

    for _, entry in ipairs(db) do
        if entry.file and entry.file:find(target, 1, true) then
            local tokens = entry.arguments
                or vim.split(entry.command or '', '%s+', { trimempty = true })
            if #tokens < 2 then
                return
            end

            local compiler = tokens[1]
            local flags, skip = {}, false
            for i = 2, #tokens do
                if skip then
                    skip = false
                elseif tokens[i] == '-o' or tokens[i] == '-c' then
                    skip = true
                elseif
                    tokens[i] == entry.file
                    or tokens[i]:find(target, 1, true)
                    or tokens[i]:match('^%-M')
                then
                -- skip
                else
                    flags[#flags + 1] = tokens[i]
                end
            end
            return { compiler = compiler, args = flags }
        end
    end
end

---@param source string
---@param callback fun(lines: string[])
local function compile_to_asm(source, callback)
    local build_dir = get_build_dir()
    if not build_dir then
        vim.notify(
            'No compile_commands.json — run :CMakeGenerate',
            vim.log.levels.ERROR,
            { title = 'asm' }
        )
        return
    end
    local entry = parse_entry(build_dir)
    if not entry then
        vim.notify(
            'File not in compile_commands.json — rebuild target',
            vim.log.levels.ERROR,
            { title = 'asm' }
        )
        return
    end

    local outfile = vim.fn.tempname() .. '.s'
    local cmd = { entry.compiler }
    vim.list_extend(cmd, entry.args)
    vim.list_extend(
        cmd,
        {
            '-S',
            '-masm=intel',
            '-g1',
            '-fno-asynchronous-unwind-tables',
            '-o',
            outfile,
            source,
        }
    )

    vim.system(cmd, { text = true, cwd = build_dir }, function(out)
        vim.schedule(function()
            if out.code ~= 0 then
                vim.notify(
                    vim.trim(out.stderr or out.stdout or 'Unknown error'),
                    vim.log.levels.ERROR,
                    { title = 'asm' }
                )
                return
            end
            local lines = vim.fn.readfile(outfile)
            pcall(vim.uv.fs_unlink, outfile)
            callback(lines)
        end)
    end)
end

---@param lines string[]
local function render(lines)
    -- Filter noise: directives, debug sections, alignment padding
    ---@type string[]
    local filtered = vim.iter(lines)
        :filter(function(l)
            if l:match('^%s*%.cfi_') then
                return false
            end
            if l:match('^%s*%.file%s') then
                return false
            end
            if l:match('^%s*%.loc%s') then
                return false
            end
            if l:match('^%s*%.p2align') then
                return false
            end
            return true
        end)
        :totable()

    if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
        vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, filtered)
    else
        M.buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, filtered)
        vim.bo[M.buf].filetype = 'asm'
        vim.bo[M.buf].bufhidden = 'wipe'
        vim.bo[M.buf].modifiable = false
        vim.bo[M.buf].buftype = 'nofile'
    end

    if not (M.win and vim.api.nvim_win_is_valid(M.win)) then
        vim.cmd('vsplit')
        M.win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(M.win, M.buf)
        vim.wo[M.win].number = false
        vim.wo[M.win].relativenumber = false
        vim.wo[M.win].signcolumn = 'no'
        vim.wo[M.win].foldcolumn = '0'
        vim.wo[M.win].wrap = false
    end

    -- Unlock, write, re-lock
    vim.bo[M.buf].modifiable = true
    vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, filtered)
    vim.bo[M.buf].modifiable = false
end

local function refresh()
    local source = vim.api.nvim_buf_get_name(0)
    if source == '' then
        return
    end
    compile_to_asm(source, render)
end

local function open()
    refresh()
    -- Auto-refresh on save
    if not M.augroup then
        M.augroup =
            vim.api.nvim_create_augroup('AsmViewLocal', { clear = true })
        vim.api.nvim_create_autocmd('BufWritePost', {
            group = M.augroup,
            pattern = { '*.c', '*.cpp', '*.cc', '*.cxx', '*.h', '*.hpp' },
            callback = refresh,
        })
    end
end

local function close()
    if M.win and vim.api.nvim_win_is_valid(M.win) then
        vim.api.nvim_win_close(M.win, true)
    end
    if M.augroup then
        vim.api.nvim_del_augroup_by_id(M.augroup)
        M.augroup = nil
    end
    M.win = nil
    M.buf = nil
end

local function toggle()
    if M.win and vim.api.nvim_win_is_valid(M.win) then
        close()
    else
        open()
    end
end

local function diagnostics()
    local build_dir = get_build_dir()
    local ok_cmake, cmake = pcall(require, 'cmake-tools')
    ---@type string[]
    local lines = {
        ('Build dir:  %s'):format(build_dir or 'NOT FOUND'),
        ('Preset:     %s'):format(
            ok_cmake
                    and cmake.get_configure_preset
                    and cmake.get_configure_preset()
                or 'n/a'
        ),
        ('Kit:        %s'):format(
            ok_cmake and cmake.get_kit and cmake.get_kit() or 'n/a'
        ),
        ('Build type: %s'):format(
            ok_cmake and cmake.get_build_type and cmake.get_build_type()
                or 'n/a'
        ),
    }
    if build_dir then
        local entry = parse_entry(build_dir)
        if entry then
            lines[#lines + 1] = ('Compiler:   %s'):format(entry.compiler)
            lines[#lines + 1] = ('Flags:      %s'):format(
                table.concat(entry.args, ' ')
            )
        end
    end
    vim.notify(
        table.concat(lines, '\n'),
        vim.log.levels.INFO,
        { title = 'asm diagnostics' }
    )
end

---@type LazyPluginSpec[]
return {
    {
        name = 'asmview-local',
        dir = vim.fn.stdpath('config'),
        dependencies = { 'Civitasv/cmake-tools.nvim' },
        keys = {
            {
                '<leader>caa',
                toggle,
                desc = 'ASM: Toggle (CMake)',
                ft = { 'c', 'cpp' },
            },
            {
                '<leader>car',
                refresh,
                desc = 'ASM: Refresh',
                ft = { 'c', 'cpp' },
            },
            {
                '<leader>cad',
                diagnostics,
                desc = 'ASM: Diagnostics',
                ft = { 'c', 'cpp' },
            },
        },
    },
    {
        'folke/which-key.nvim',
        opts = {
            spec = {
                {
                    '<leader>ca',
                    group = 'Assembly',
                    icon = { icon = '', color = 'red' },
                },
            },
        },
    },
}
