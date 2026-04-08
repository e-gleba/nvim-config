-- lua/plugins/asmview.lua

---@class AsmState
---@field buf integer?
---@field win integer?
---@field src_buf integer?
---@field aug integer?
---@field map table<integer, integer>
local S = { map = {} }

local NS = vim.api.nvim_create_namespace('asmview')

---@type string[]
local NOISE = {
    '^%s*%.cfi_',
    '^%s*%.file%s',
    '^%s*%.p2align',
    '^%s*%.addrsig',
    '^%s*%.ident',
    '^%s*%.section%s+%.debug',
    '^%s*%.section%s+%.note',
}

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
    for _, d in ipairs({
        '',
        'build',
        'cmake-build-debug',
        'cmake-build-release',
        'out/build',
    }) do
        local p = d == '' and root or vim.fs.joinpath(root, d)
        if vim.uv.fs_stat(vim.fs.joinpath(p, 'compile_commands.json')) then
            return p
        end
    end
end

---@param db_path string
---@return table?
local function read_compiledb(db_path)
    local ok, db =
        pcall(vim.json.decode, table.concat(vim.fn.readfile(db_path), '\n'))
    if ok and type(db) == 'table' then
        return db
    end
end

---@param entry table
---@return string compiler, string[] flags
local function extract_flags(entry)
    local tok = entry.arguments
        or vim.split(entry.command or '', '%s+', { trimempty = true })
    local compiler, flags, skip = tok[1], {}, false
    for i = 2, #tok do
        if skip then
            skip = false
        elseif tok[i]:match('^[/-][co]$') or tok[i]:match('^/F[ao]') then
            skip = true
        elseif tok[i] == entry.file or tok[i]:match('^%-M') then
        -- skip source ref / dep generation
        else
            flags[#flags + 1] = tok[i]
        end
    end
    return compiler, flags
end

---@param build_dir string
---@param source_path string
---@return { compiler: string, args: string[], unity: boolean }?
local function resolve_entry(build_dir, source_path)
    local db_path = vim.fs.joinpath(build_dir, 'compile_commands.json')
    local db = read_compiledb(db_path)
    if not db then
        return
    end

    local basename = vim.fs.basename(source_path)
    local abs = vim.uv.fs_realpath(source_path) or source_path

    -- Pass 1: direct match (normal non-unity build)
    for _, e in ipairs(db) do
        if e.file then
            local efile = vim.uv.fs_realpath(e.file) or e.file
            if efile == abs or e.file:find(basename, 1, true) then
                local compiler, flags = extract_flags(e)
                return { compiler = compiler, args = flags, unity = false }
            end
        end
    end

    -- Pass 2: unity build — find which unity_*.cxx #includes our file
    ---@type table[]
    local unity_entries = vim.iter(db)
        :filter(function(e)
            if not e.file then
                return false
            end
            local f = e.file:lower()
            return f:find('unity', 1, true) or f:find('jumbo', 1, true)
        end)
        :totable()

    for _, e in ipairs(unity_entries) do
        local unity_file = e.file
        -- Resolve relative to directory field if present
        if e.directory and not vim.startswith(unity_file, '/') then
            unity_file = vim.fs.joinpath(e.directory, unity_file)
        end
        if vim.uv.fs_stat(unity_file) then
            for _, line in ipairs(vim.fn.readfile(unity_file)) do
                -- Unity files contain: #include "/absolute/path/to/source.cpp"
                -- or:                  #include "relative/path/to/source.cpp"
                local inc = line:match('^%s*#%s*include%s*"([^"]+)"')
                if inc then
                    local inc_abs = vim.uv.fs_realpath(inc)
                        or (
                            e.directory
                            and vim.uv.fs_realpath(
                                vim.fs.joinpath(e.directory, inc)
                            )
                        )
                    if
                        inc_abs == abs or (inc and inc:find(basename, 1, true))
                    then
                        local compiler, flags = extract_flags(e)
                        return {
                            compiler = compiler,
                            args = flags,
                            unity = true,
                        }
                    end
                end
            end
        end
    end
end

---@param compiler string
---@return boolean
local function is_msvc(compiler)
    local b = vim.fs.basename(compiler):lower()
    return b == 'cl.exe' or b == 'cl'
end

---@param raw string[]
---@return string[] lines, table<integer, integer> map
local function process(raw)
    if vim.fn.executable('c++filt') == 1 then
        local r = vim.system(
            { 'c++filt' },
            { stdin = table.concat(raw, '\n'), text = true }
        ):wait()
        if r.code == 0 then
            raw = vim.split(r.stdout, '\n', { trimempty = true })
        end
    end

    local lines, map, src = {}, {}, 0
    for _, line in ipairs(raw) do
        local loc = line:match('^%s*%.loc%s+%d+%s+(%d+)')
            or line:match('^;%s*Line%s+(%d+)')
        if loc then
            src = tonumber(loc) or 0
        else
            local noise = false
            for _, p in ipairs(NOISE) do
                if line:match(p) then
                    noise = true
                    break
                end
            end
            if not noise then
                lines[#lines + 1] = line
                if src > 0 then
                    map[#lines] = src
                end
            end
        end
    end
    return lines, map
end

local function sync_forward()
    if not (S.buf and S.src_buf and S.win) then
        return
    end
    if not vim.api.nvim_buf_is_valid(S.buf) then
        return
    end
    if vim.api.nvim_get_current_buf() ~= S.src_buf then
        return
    end

    vim.api.nvim_buf_clear_namespace(S.buf, NS, 0, -1)
    local cur = vim.api.nvim_win_get_cursor(0)[1]
    local first = nil
    for asm_ln, src_ln in pairs(S.map) do
        if src_ln == cur then
            pcall(
                vim.api.nvim_buf_add_highlight,
                S.buf,
                NS,
                'CurSearch',
                asm_ln - 1,
                0,
                -1
            )
            if not first or asm_ln < first then
                first = asm_ln
            end
        end
    end
    if first and vim.api.nvim_win_is_valid(S.win) then
        pcall(vim.api.nvim_win_set_cursor, S.win, { first, 0 })
    end
end

local function sync_reverse()
    if not (S.buf and S.src_buf) then
        return
    end
    if vim.api.nvim_get_current_buf() ~= S.buf then
        return
    end
    if not vim.api.nvim_buf_is_valid(S.src_buf) then
        return
    end

    vim.api.nvim_buf_clear_namespace(S.src_buf, NS, 0, -1)
    local asm_ln = vim.api.nvim_win_get_cursor(0)[1]
    local src_ln = S.map[asm_ln]
    if not src_ln then
        for l = asm_ln - 1, 1, -1 do
            if S.map[l] then
                src_ln = S.map[l]
                break
            end
        end
    end
    if not src_ln then
        return
    end

    pcall(
        vim.api.nvim_buf_add_highlight,
        S.src_buf,
        NS,
        'CurSearch',
        src_ln - 1,
        0,
        -1
    )
    for _, w in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(w) == S.src_buf then
            pcall(vim.api.nvim_win_set_cursor, w, { src_ln, 0 })
            break
        end
    end
end

---@param lines string[]
local function render(lines)
    local new_buf = false
    if not (S.buf and vim.api.nvim_buf_is_valid(S.buf)) then
        S.buf = vim.api.nvim_create_buf(false, true)
        vim.bo[S.buf].filetype = 'asm'
        vim.bo[S.buf].buftype = 'nofile'
        vim.bo[S.buf].bufhidden = 'wipe'
        pcall(vim.api.nvim_buf_set_name, S.buf, '[ASM]')
        new_buf = true
    end

    vim.bo[S.buf].modifiable = true
    vim.api.nvim_buf_set_lines(S.buf, 0, -1, false, lines)
    vim.bo[S.buf].modifiable = false

    if not (S.win and vim.api.nvim_win_is_valid(S.win)) then
        local src_win = vim.api.nvim_get_current_win()
        vim.cmd('vsplit')
        S.win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(S.win, S.buf)
        vim.wo[S.win].number = false
        vim.wo[S.win].relativenumber = false
        vim.wo[S.win].signcolumn = 'no'
        vim.wo[S.win].foldcolumn = '0'
        vim.wo[S.win].wrap = false
        vim.api.nvim_set_current_win(src_win)
    end

    if new_buf and S.aug then
        vim.api.nvim_create_autocmd('CursorMoved', {
            group = S.aug,
            buffer = S.buf,
            callback = sync_reverse,
        })
    end
end

local function refresh()
    local source = vim.api.nvim_buf_get_name(0)
    if source == '' or vim.bo.buftype ~= '' then
        return
    end
    S.src_buf = vim.api.nvim_get_current_buf()

    local build_dir = get_build_dir()
    if not build_dir then
        return vim.notify(
            'No compile_commands.json — run :CMakeGenerate',
            vim.log.levels.ERROR,
            { title = 'asm' }
        )
    end

    local entry = resolve_entry(build_dir, source)
    if not entry then
        return vim.notify(
            'File not in compile_commands.json (checked direct + unity entries)\nRebuild target or check UNITY_BUILD grouping',
            vim.log.levels.ERROR,
            { title = 'asm' }
        )
    end

    if entry.unity then
        vim.notify(
            'Unity build detected — compiling single TU with unity flags',
            vim.log.levels.INFO,
            { title = 'asm' }
        )
    end

    local outfile = vim.fn.tempname() .. '.s'
    local cmd = { entry.compiler }
    vim.list_extend(cmd, entry.args)
    -- Always compile the REAL source file, even if flags came from a unity entry
    vim.list_extend(
        cmd,
        is_msvc(entry.compiler) and { '/FA', '/Fa' .. outfile, source }
            or {
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
                return vim.notify(
                    vim.trim(out.stderr or out.stdout or 'Compilation failed'),
                    vim.log.levels.ERROR,
                    { title = 'asm' }
                )
            end
            local raw = vim.fn.readfile(outfile)
            pcall(vim.uv.fs_unlink, outfile)
            local lines, map = process(raw)
            S.map = map
            render(lines)
            sync_forward()
        end)
    end)
end

local function close()
    if S.src_buf and vim.api.nvim_buf_is_valid(S.src_buf) then
        vim.api.nvim_buf_clear_namespace(S.src_buf, NS, 0, -1)
    end
    if S.buf and vim.api.nvim_buf_is_valid(S.buf) then
        vim.api.nvim_buf_clear_namespace(S.buf, NS, 0, -1)
    end
    if S.win and vim.api.nvim_win_is_valid(S.win) then
        vim.api.nvim_win_close(S.win, true)
    end
    if S.aug then
        pcall(vim.api.nvim_del_augroup_by_id, S.aug)
        S.aug = nil
    end
    S.win, S.buf, S.src_buf, S.map = nil, nil, nil, {}
end

local function open()
    S.src_buf = vim.api.nvim_get_current_buf()
    refresh()
    if not S.aug then
        S.aug = vim.api.nvim_create_augroup('AsmView', { clear = true })
        vim.api.nvim_create_autocmd('BufWritePost', {
            group = S.aug,
            buffer = S.src_buf,
            callback = function()
                if S.win and vim.api.nvim_win_is_valid(S.win) then
                    refresh()
                end
            end,
        })
        vim.api.nvim_create_autocmd('CursorMoved', {
            group = S.aug,
            buffer = S.src_buf,
            callback = sync_forward,
        })
    end
end

local function toggle()
    if S.win and vim.api.nvim_win_is_valid(S.win) then
        close()
    else
        open()
    end
end

local function diag()
    local bd = get_build_dir()
    local source = vim.api.nvim_buf_get_name(0)
    local ok, cm = pcall(require, 'cmake-tools')

    ---@type string[]
    local info = {
        ('Build dir:  %s'):format(bd or 'NOT FOUND'),
        ('Preset:     %s'):format(
            ok and cm.get_configure_preset and cm.get_configure_preset()
                or 'n/a'
        ),
        ('Kit:        %s'):format(ok and cm.get_kit and cm.get_kit() or 'n/a'),
        ('Build type: %s'):format(
            ok and cm.get_build_type and cm.get_build_type() or 'n/a'
        ),
        ('Demangle:   %s'):format(
            vim.fn.executable('c++filt') == 1 and 'c++filt' or 'unavailable'
        ),
    }

    if bd and source ~= '' then
        local entry = resolve_entry(bd, source)
        if entry then
            info[#info + 1] = ('Compiler:   %s'):format(entry.compiler)
            info[#info + 1] = ('MSVC:       %s'):format(
                is_msvc(entry.compiler) and 'yes' or 'no'
            )
            info[#info + 1] = ('Unity:      %s'):format(
                entry.unity and 'yes (flags from unity TU)'
                    or 'no (direct entry)'
            )
            info[#info + 1] = ('Flags:      %s'):format(
                table.concat(entry.args, ' ')
            )
        else
            info[#info + 1] = 'Entry:      NOT FOUND (direct or unity)'
        end
    end

    vim.notify(table.concat(info, '\n'), vim.log.levels.INFO, { title = 'asm' })
end

---@type LazyPluginSpec[]
return {
    {
        name = 'asmview',
        dir = vim.fn.stdpath('config'),
        dependencies = { 'Civitasv/cmake-tools.nvim' },
        keys = {
            {
                '<leader>caa',
                toggle,
                desc = 'ASM: Toggle',
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
                diag,
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
