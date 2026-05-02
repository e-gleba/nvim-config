--- Generate Doxygen / Javadoc annotations from C++ function signatures.
--- Place cursor on a method, trigger mapping, and param/return blocks are auto-written.
--- Refs:
---   https://github.com/danymat/neogen
---   https://github.com/nvim-treesitter/nvim-treesitter
return {
    'danymat/neogen',
    keys = {
        {
            '<leader>cn',
            function()
                require('neogen').generate()
            end,
            desc = 'Generate doc comment',
        },
    },
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = { snippet_engine = 'luasnip' },
}
