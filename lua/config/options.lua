-- Options -- loaded automatically before lazy.nvim startup
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- This file only contains *overrides*. Anything not set here inherits from LazyVim.

local opt = vim.opt
local g = vim.g
local is_win = vim.fn.has('win32') == 1

-- Encoding --
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

opt.fileformats = 'unix,dos'
opt.fileformat = 'unix'
opt.fixendofline = true

-- Indentation --
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

-- Gutter --
-- Enable signcolumn so LSP diagnostics, gitsigns, and DAP breakpoints
-- are visible. Hiding it saves 2 columns but breaks IDE experience.
-- https://neovim.io/doc/user/options.html#'signcolumn'
opt.signcolumn = 'yes:2'

-- Python Tooling --
-- LazyVim reads these globals to decide LSP and linter in `lang.python`.
-- https://lazyvim.github.io/extras/lang/python
g.lazyvim_python_lsp = 'basedpyright'
g.lazyvim_python_ruff = 'ruff'

-- Windows -- PowerShell as default shell --
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

if vim.env.SSH_TTY then
    vim.opt.clipboard = 'unnamedplus'

    local osc52 = require('vim.ui.clipboard.osc52')

    -- Terminals that support OSC 52 *read* (paste)
    local term = vim.env.TERM_PROGRAM or ''
    local can_osc52_paste = term == 'ghostty' or term == 'kitty'

    local function local_paste()
        return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
    end

    vim.g.clipboard = {
        name = 'OSC 52',
        copy = {
            ['+'] = osc52.copy('+'),
            ['*'] = osc52.copy('*'),
        },
        paste = {
            ['+'] = can_osc52_paste and osc52.paste('+') or local_paste,
            ['*'] = can_osc52_paste and osc52.paste('*') or local_paste,
        },
    }
end
