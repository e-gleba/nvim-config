-- Options — loaded automatically before lazy.nvim startup
-- https://lazyvim.github.io/configuration/general
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
--
-- This file only contains *overrides*. Anything not set here inherits
-- from LazyVim's defaults. Values here win because this file loads
-- after the LazyVim options module.

local opt = vim.opt
local g = vim.g
local is_win = vim.fn.has('win32') == 1

-- Encoding
-- `vim.o.encoding` defaults to UTF-8 in Neovim, but `fileencoding`
-- (the encoding written to disk) does not — set it explicitly.
-- https://neovim.io/doc/user/options.html#'fileencoding'
opt.fileencoding = 'utf-8'

-- Line endings — force LF on every buffer regardless of OS or Git checkout mode.
-- `fileformat` is buffer-local; a global `opt.fileformat` only affects new empty
-- buffers. When a file is read from disk Neovim auto-detects from `fileformats`,
-- so Git `core.autocrlf=true` on Windows silently produces `dos` buffers even
-- though the user asked for `unix`. This autocmd overrides detection after every
-- read and strips any stray carriage returns so the buffer is clean for the LSP.
-- https://neovim.io/doc/user/options.html#'fileformat'
-- https://neovim.io/doc/user/options.html#'fileformats'
-- https://neovim.io/doc/user/editing.html#file-formats
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
    group = vim.api.nvim_create_augroup('ForceUnixLf', { clear = true }),
    pattern = '*',
    callback = function()
        -- Always write with LF; ensure the file ends with a newline.
        -- https://neovim.io/doc/user/options.html#'fixendofline'
        vim.bo.fileformat = 'unix'
        vim.bo.fixendofline = true

        -- If Git checked out CRLF, strip literal ^M from the buffer text so the
        -- file renders cleanly and the LSP sees pure LF content. Uses `search()`
        -- to avoid a no-op substitution when there are no carriage returns.
        if vim.fn.search('\r', 'nw') > 0 then
            local view = vim.fn.winsaveview()
            vim.cmd([[keeppatterns silent! %s/\r$//e]])
            vim.fn.winrestview(view)
        end
    end,
})

-- Indentation
-- 4-space indent, hard tabs expanded. `textwidth` at 80 enables `gq`
-- paragraph formatting; actual wrapping is off (`wrap = false`).
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
-- Enable the signcolumn so LSP diagnostics, gitsigns changes, and DAP
-- breakpoints are visible in the left gutter. Hiding it saves 2 columns
-- but breaks the IDE experience (you cannot see where errors or breakpoints
-- live without opening the line).
-- https://neovim.io/doc/user/options.html#'signcolumn'
opt.signcolumn = 'yes:2'

-- Python Tooling
-- LazyVim reads these globals to decide which LSP and linter to
-- configure in the `lang.python` extra.
-- https://lazyvim.github.io/extras/lang/python
g.lazyvim_python_lsp = 'basedpyright'
g.lazyvim_python_ruff = 'ruff'

-- Windows — PowerShell as default shell
-- Neovim on Windows defaults to cmd.exe. PowerShell provides a
-- POSIX-like experience (piping, environment variables, exit codes).
-- These flags mirror the recommendation from :help shell-powershell.
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
