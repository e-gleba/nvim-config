-- options.lua :: Neovim options loaded before lazy.nvim startup.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- This file only contains overrides. Anything not set here inherits from LazyVim.

local opt = vim.opt
local g = vim.g
local is_win = vim.fn.has('win32') == 1

-- Encoding -------------------------------------------------------------------
opt.fileencoding = 'utf-8'
opt.bomb = false -- never write a BOM; it breaks shebangs, CMake, and many C++ tools

-- Modeline / line endings ----------------------------------------------------
opt.modeline = false
opt.modelines = 0
opt.fileformats = 'unix,dos'
opt.fileformat = 'unix'
opt.fixendofline = true

-- Indentation ----------------------------------------------------------------
opt.textwidth = 80
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.expandtab = true
opt.wrap = false
opt.smartindent = true
opt.cindent = true
opt.cinoptions = ':0,l1,g0,t0,(0,W4'

-- Gutter ---------------------------------------------------------------------
opt.signcolumn = 'yes:2'
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.colorcolumn = '81,121'

-- Search ---------------------------------------------------------------------
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Split behavior -------------------------------------------------------------
opt.splitright = true
opt.splitbelow = true

-- Scrolling / performance ----------------------------------------------------
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.lazyredraw = false -- disabled; interferes with modern plugins
opt.ttyfast = true

-- Completion -----------------------------------------------------------------
opt.completeopt = 'menu,menuone,noselect'
opt.pumheight = 15

-- Backup / undo / swap -------------------------------------------------------
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- Python tooling (LazyVim lang.python extras) --------------------------------
g.lazyvim_python_lsp = 'basedpyright'
g.lazyvim_python_ruff = 'ruff'

-- Windows shell: PowerShell --------------------------------------------------
if is_win then
    opt.shell = 'pwsh'
    opt.shellcmdflag =
        '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
    opt.shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
    opt.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    opt.shellquote = ''
    opt.shellxquote = ''
end

-- SSH / OSC 52 clipboard -----------------------------------------------------
if vim.env.SSH_TTY then
    opt.clipboard = 'unnamedplus'

    local osc52 = require('vim.ui.clipboard.osc52')
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
