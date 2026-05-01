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

-- Encoding & File Format
-- `vim.o.encoding` defaults to UTF-8 in Neovim, but `fileencoding`
-- (the encoding written to disk) does not — set it explicitly.
-- Prefer unix line endings; fall back to dos when reading Windows files.
opt.fileencoding = 'utf-8'
opt.fileformat = 'unix'
opt.fileformats = { 'unix', 'dos' }

-- Indentation
-- 4-space indent, hard tabs expanded. `textwidth` at 80 enables `gq`
-- paragraph formatting; actual wrapping is off (`wrap = false`).
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
-- live without opening the line). See: https://neovim.io/doc/user/options.html#'signcolumn'
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
