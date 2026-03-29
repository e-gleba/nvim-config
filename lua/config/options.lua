-- lua/config/options.lua
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local o = vim.opt
local g = vim.g
local is_win = vim.fn.has('win32') == 1

---------------------------------------------------------------------------
-- encoding (vim.o.encoding defaults to utf-8 in nvim, fileencoding does not)
---------------------------------------------------------------------------
o.fileencoding = 'utf-8'
o.fileformat = 'unix'
o.fileformats = { 'unix', 'dos' }

---------------------------------------------------------------------------
-- indentation
---------------------------------------------------------------------------
o.textwidth = 80
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.expandtab = true
o.wrap = false

---------------------------------------------------------------------------
-- gutter: no sign column, diagnostics via virtual text only
---------------------------------------------------------------------------
o.signcolumn = 'no'

vim.diagnostic.config({
    signs = false,
    virtual_text = {
        spacing = 4,
        prefix = '●',
        ---@param d vim.Diagnostic
        format = function(d)
            return d.message:match('^[^\n]+') -- first line only
        end,
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = 'rounded',
        source = true,
    },
})

---------------------------------------------------------------------------
-- python tooling
---------------------------------------------------------------------------
g.lazyvim_python_lsp = 'basedpyright'
g.lazyvim_python_ruff = 'ruff'

---------------------------------------------------------------------------
-- windows: pwsh as shell
---------------------------------------------------------------------------
if is_win then
    o.shell = 'pwsh'
    o.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
    o.shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
    o.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    o.shellquote = ''
    o.shellxquote = ''
end
