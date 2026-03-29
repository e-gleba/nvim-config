---@type LazyPluginSpec[]
return {
    {
        'LazyVim/LazyVim',
        ---@type LazyVimOptions
        opts = { colorscheme = 'catppuccin' },
    },
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        lazy = true,
        priority = 1000,
        ---@type CatppuccinOptions
        opts = {
            flavour = 'latte',
            background = { light = 'latte', dark = 'mocha' },
            styles = {
                comments = { 'italic' },
                keywords = { 'bold' },
                types = { 'bold' },
                booleans = { 'bold' },
                conditionals = {},
                functions = {},
                strings = {},
                variables = {},
                numbers = {},
                properties = {},
                operators = {},
            },
            integrations = {
                cmp = true,
                flash = true,
                fzf = true,
                gitsigns = true,
                grug_far = true,
                illuminate = true,
                indent_blankline = { enabled = true },
                lsp_trouble = true,
                mason = true,
                mini = true,
                navic = { enabled = true, custom_bg = 'lualine' },
                noice = true,
                notify = true,
                snacks = true,
                treesitter = true,
                treesitter_context = true,
                which_key = true,
                native_lsp = {
                    enabled = true,
                    underlines = {
                        errors = { 'undercurl' },
                        hints = { 'undercurl' },
                        warnings = { 'undercurl' },
                        information = { 'undercurl' },
                    },
                },
            },
        },
    },
}
