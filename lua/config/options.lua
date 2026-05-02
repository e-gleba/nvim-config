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

-- Line endings -- force LF globally and on every buffer.
-- On Windows Git may check out CRLF (`core.autocrlf=true`), and the
-- cmake-language-server (or any LSP reading from disk) will see `\\r\\n`.
-- Five layers of defense:
--   1. `.gitattributes` in repo root -- forces Git to normalize to LF on checkout.
--   2. `fileformats` -- auto-detection order prefers unix over dos.
--   3. `fileformat`  -- default for new empty buffers.
--   4. Autocmds      -- override after read and before write so buffers are
--      always `unix` and literal `\\r` is stripped before LSP sees text.
--   5. `fixendofline` / `endofline` -- ensure POSIX-compliant trailing newline.
-- https://neovim.io/doc/user/options.html#'fileformat'
-- https://neovim.io/doc/user/options.html#'fileformats'
-- https://neovim.io/doc/user/options.html#'fixendofline'
-- https://neovim.io/doc/user/options.html#'endofline'
-- https://neovim.io/doc/user/editing.html#file-formats
-- https://git-scm.com/docs/gitattributes#_end_of_line_conversion
opt.fileformats = 'unix,dos' -- try unix first when reading
opt.fileformat = 'unix'      -- default for new empty buffers
opt.fixendofline = true      -- ensure POSIX trailing newline on write
opt.endofline = true         -- write trailing newline

local force_lf_au = vim.api.nvim_create_augroup('ForceUnixLf', { clear = true })

-- After reading or creating a file: lock to LF and strip stray ^M.
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
    group = force_lf_au,
    pattern = '*',
    callback = function()
        -- Lock format to unix so writes produce LF only.
        vim.bo.fileformat = 'unix'
        -- Ensure buffer-local fixendofline is enabled.
        vim.bo.fixendofline = true

        -- If Git checked out CRLF and Neovim missed it (mixed-format
        -- file or `fileformats` disabled), strip literal carriage returns.
        if vim.fn.search('\\r', 'nw') > 0 then
            local view = vim.fn.winsaveview()
            vim.cmd([[keeppatterns silent! %s/\\r$//e]])
            vim.fn.winrestview(view)
        end
    end,
})

-- Before every write: re-affirm unix format (prevents plugins from
-- flipping it back to dos after the BufReadPost autocmd).
vim.api.nvim_create_autocmd('BufWritePre', {
    group = force_lf_au,
    pattern = '*',
    callback = function()
        vim.bo.fileformat = 'unix'
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
