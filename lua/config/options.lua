-- Options -- loaded automatically before lazy.nvim startup
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- This file only contains *overrides*. Anything not set here inherits from LazyVim.

local opt = vim.opt
local g = vim.g
local is_win = vim.fn.has('win32') == 1

-- Encoding
-- `fileencoding` (written to disk) defaults to UTF-8 in Neovim, but be explicit.
-- https://neovim.io/doc/user/options.html#'fileencoding'
opt.fileencoding = 'utf-8'

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
--   5. After read: strip literal `\r` left by `fileformats=unix`.
--      Pure Lua -- no vim.cmd string escaping, no winrestview fragility.
--   6. Before write: reaffirm `unix` so plugins cannot flip to dos.
--
-- https://git-scm.com/docs/gitattributes#_end_of_line_conversion

vim.g.editorconfig = false

opt.fileformats = 'unix'
opt.fileformat = 'unix'
opt.fixendofline = true

local force_lf_au = vim.api.nvim_create_augroup('ForceLf', { clear = true })

-- After reading a file: strip stray carriage returns.
-- When Git checks out CRLF on Windows, Neovim reads as unix format
-- and the `\r` stays as a literal trailing character. We remove it
-- with a pure Lua loop so LSPs never see DOS line endings.
vim.api.nvim_create_autocmd('BufReadPost', {
    group = force_lf_au,
    pattern = '*',
    callback = function(args)
        if vim.bo[args.buf].buftype ~= '' then
            return
        end
        local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
        local dirty = false
        for i, line in ipairs(lines) do
            if line:sub(-1) == '\r' then
                lines[i] = line:sub(1, -2)
                dirty = true
            end
        end
        if dirty then
            vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
            vim.bo[args.buf].fileformat = 'unix'
        end
    end,
})

-- Before every write: lock to LF.
vim.api.nvim_create_autocmd('BufWritePre', {
    group = force_lf_au,
    pattern = '*',
    callback = function(args)
        vim.bo[args.buf].fileformat = 'unix'
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
