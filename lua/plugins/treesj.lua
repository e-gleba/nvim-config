--- Toggle single-line / multi-line C++ syntax blocks.
--- Useful for function arguments, initializer lists, if/else braces.
--- Refs:
---   https://github.com/Wansmer/treesj
---   https://github.com/nvim-treesitter/nvim-treesitter
return {
    'Wansmer/treesj',
    keys = {
        {
            '<leader>cm',
            function()
                require('treesj').toggle()
            end,
            desc = 'Toggle syntax block',
        },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = { use_default_keymaps = false },
}
