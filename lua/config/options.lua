-- Options -- loaded automatically before lazy.nvim startup
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- This file only contains *overrides*. Anything not set here inherits from LazyVim.

local opt = vim.opt
local g = vim.g
local is_win = vim.fn.has('win32') == 1

-- Encoding
-- `fileencoding` (written to disk) defaults to UTF-8 in Neovim; be explicit.
-- https://neovim.io/doc/user/options.html#'fileencoding'
opt.fileencoding = 'utf-8'

-- BOM (Byte Order Mark) -- never write it. BOM breaks shebangs, CMake,
-- and many C++ compilers / LSPs.
-- https://neovim.io/doc/user/options.html#'bomb'
opt.bomb = false

-- Modeline -- disable entirely. A `vim:ff=dos:` modeline in a third-party
-- header silently overrides our line-ending policy.
-- https://neovim.io/doc/user/options.html#'modeline'
opt.modeline = false
opt.modelines = 0

-- Line endings -- force LF everywhere, unconditionally.
-- On Windows Git may check out CRLF (`core.autocrlf=true`), and LSPs
-- reading from disk (cmake-language-server, clangd on first scan) see
-- `\r\n`. We remove ALL possibility of DOS format:
--
--   1. Disable EditorConfig globally. A parent `.editorconfig` with
--      `end_of_line = crlf` silently overrides Neovim options.
--      https://neovim.io/doc/user/editorconfig.html
--   2. `fileformats = 'unix'` -- Neovim NEVER attempts dos/mac detection.
--      https://neovim.io/doc/user/options.html#'fileformats'
--   3. `fileformat = 'unix'` -- default for new empty buffers.
--      https://neovim.io/doc/user/options.html#'fileformat'
--   4. `fixendofline = true` -- POSIX-compliant trailing newline on write.
--      https://neovim.io/doc/user/options.html#'fixendofline'
--   5. `endofline = true` -- buffer always claims to end with a newline.
--      https://neovim.io/doc/user/options.html#'endofline'
--
-- https://git-scm.com/docs/gitattributes#_end_of_line_conversion

vim.g.editorconfig = false

opt.fileformats = 'unix'
opt.fileformat = 'unix'
opt.fixendofline = true
opt.endofline = true

local force_lf_au = vim.api.nvim_create_augroup('ForceLf', { clear = true })

-- After reading any file: strip every carriage return, lock to unix,
-- and clear the modified flag. We do this unconditionally so a plugin
-- or modeline that snuck in during read is overwritten.
vim.api.nvim_create_autocmd('BufReadPost', {
    group = force_lf_au,
    pattern = '*',
    callback = function(args)
        local bo = vim.bo[args.buf]
        if bo.buftype ~= '' or bo.binary then
            return
        end
        local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
        local dirty = false
        for i, line in ipairs(lines) do
            if line:find('\r', 1, true) then
                lines[i] = line:gsub('\r', '')
                dirty = true
            end
        end
        if dirty then
            vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
            bo.modified = false
        end
        bo.fileformat = 'unix'
    end,
})

-- New empty buffers: start in LF mode.
vim.api.nvim_create_autocmd('BufNewFile', {
    group = force_lf_au,
    pattern = '*',
    callback = function(args)
        vim.bo[args.buf].fileformat = 'unix'
    end,
})

-- Before every write: reaffirm unix so plugins cannot flip to dos.
vim.api.nvim_create_autocmd('BufWritePre', {
    group = force_lf_au,
    pattern = '*',
    callback = function(args)
        vim.bo[args.buf].fileformat = 'unix'
    end,
})

-- After full startup: stomp any plugin that reset fileformats behind us.
vim.api.nvim_create_autocmd('VimEnter', {
    group = force_lf_au,
    once = true,
    callback = function()
        vim.opt.fileformats = 'unix'
    end,
})

-- Indentation
-- 4-space indent, hard tabs expanded. `textwidth` at 80 enables `gq`.
-- https://neovim.io/doc/user/options.html#'textwidth'
-- https://neovim.io/doc/user/options.html#'shiftwidth'
-- https://neovim.io/doc/user/options.html#'tabstop'
-- https://neovim.io/doc/user/options.html#'softtabstop'
-- https://neovim.io/doc/user/options.html#'expandtab'
-- https://neovim.io/doc/user/options.html#'wrap'
opt.textwidth = 80
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.expandtab = true
opt.wrap = false

-- Gutter
-- Enable signcolumn so LSP diagnostics, gitsigns, and DAP breakpoints
-- are visible. Hiding it saves 2 columns but breaks IDE experience.
-- https://neovim.io/doc/user/options.html#'signcolumn'
opt.signcolumn = 'yes:2'

-- Python Tooling
-- LazyVim reads these globals to decide LSP and linter in `lang.python`.
-- https://lazyvim.github.io/extras/lang/python
g.lazyvim_python_lsp = 'basedpyright'
g.lazyvim_python_ruff = 'ruff'

-- Windows -- PowerShell as default shell
-- Neovim on Windows defaults to cmd.exe. PowerShell provides POSIX-like
-- piping and exit codes. Mirrors :help shell-powershell.
-- https://neovim.io/doc/user/options.html#'shell'
if is_win then
    opt.shell = 'pwsh'
    opt.shellcmdflag =
        '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
    opt.shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
    opt.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    opt.shellquote = ''
    opt.shellxquote = ''
end
