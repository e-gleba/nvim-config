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

-- Line endings -- LF-only, automatic, zero manual intervention.
--
-- On Windows, Git may check out CRLF (`core.autocrlf=true`). LSPs reading
-- from disk (`cmake-language-server`, `clangd`) then see `\r\n` and complain.
-- We solve this with built-in Neovim mechanisms, not manual buffer surgery:
--
--   1. `fileformats = 'unix,dos'` -- Neovim detects CRLF files as `dos`
--      so they display cleanly (no literal `^M`). Existing LF files stay
--      `unix`. https://neovim.io/doc/user/options.html#'fileformats'
--
--   2. `fileformat = 'unix'` -- default for new empty buffers.
--      https://neovim.io/doc/user/options.html#'fileformat'
--
--   3. `fixendofline = true` -- POSIX-compliant trailing newline on write.
--      https://neovim.io/doc/user/options.html#'fixendofline'
--
--   4. `endofline = true` -- buffer always claims a trailing newline.
--      https://neovim.io/doc/user/options.html#'endofline'
--
--   5. `BufReadPost` -- any file detected as `dos` is converted in-memory
--      to `unix` and marked *modified*. The next write stores LF to disk.
--      No manual `:set ff=unix` ever required.
--
--   6. `BufWritePre` / `BufNewFile` / `VimEnter` -- guard rails that
--      prevent plugins from flipping back to `dos` behind us.
--
-- https://git-scm.com/docs/gitattributes#_end_of_line_conversion
--
-- Disable EditorConfig globally so a parent `.editorconfig` with
-- `end_of_line = crlf` cannot override us.
-- https://neovim.io/doc/user/editorconfig.html
g.editorconfig = false

opt.fileformats = 'unix,dos'
opt.fileformat = 'unix'
opt.fixendofline = true
opt.endofline = true

local lf_au = vim.api.nvim_create_augroup('LfEnforcement', { clear = true })

-- After reading: convert detected DOS → Unix in-memory.
-- Buffer is marked modified; user saves once and disk is forever LF.
vim.api.nvim_create_autocmd('BufReadPost', {
    group = lf_au,
    pattern = '*',
    callback = function(args)
        if vim.bo[args.buf].fileformat == 'dos' then
            vim.bo[args.buf].fileformat = 'unix'
        end
    end,
})

-- Before every write: reaffirm Unix so plugins cannot flip to DOS.
vim.api.nvim_create_autocmd('BufWritePre', {
    group = lf_au,
    pattern = '*',
    callback = function(args)
        vim.bo[args.buf].fileformat = 'unix'
    end,
})

-- New empty buffers: start in LF mode.
vim.api.nvim_create_autocmd('BufNewFile', {
    group = lf_au,
    pattern = '*',
    callback = function(args)
        vim.bo[args.buf].fileformat = 'unix'
    end,
})

-- After full startup: stomp any plugin that reset fileformats behind us.
vim.api.nvim_create_autocmd('VimEnter', {
    group = lf_au,
    once = true,
    callback = function()
        vim.opt.fileformats = 'unix,dos'
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
