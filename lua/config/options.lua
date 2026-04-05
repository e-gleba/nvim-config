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
-- Hide the sign column entirely. Diagnostics are surfaced through
-- virtual text and underlines instead of gutter icons. This reclaims
-- 2-3 columns of horizontal space on every window.
opt.signcolumn = 'no'

-- Diagnostics
-- Configured here (not in a plugin spec) because `vim.diagnostic.config`
-- is a global Neovim API, not a plugin option. Setting it in options.lua
-- guarantees it applies before any LSP client attaches.
-- https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.config()
vim.diagnostic.config({
    -- Disable gutter signs (consistent with signcolumn = "no" above)
    signs = false,

    -- Inline virtual text at the end of each diagnostic line
    virtual_text = {
        -- Gap between end-of-line and the virtual text
        spacing = 4,
        -- Prefix glyph before the diagnostic message
        prefix = '●',
        -- Truncate multi-line diagnostics to the first line to keep
        -- the buffer readable. Full text is still available in the float.
        ---@param diagnostic vim.Diagnostic
        format = function(diagnostic)
            return diagnostic.message:match('^[^\n]+')
        end,
    },

    -- Underline the offending range (works with undercurl in supported terminals)
    underline = true,

    -- Suppress diagnostics while typing — reduces visual noise in insert mode
    update_in_insert = false,

    -- Errors sort above warnings above hints in virtual text and floats
    severity_sort = true,

    -- Floating window shown by `vim.diagnostic.open_float()` / `<leader>cd`
    float = {
        border = 'rounded',
        -- Show which LSP / linter produced the diagnostic
        source = true,
    },
})

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
