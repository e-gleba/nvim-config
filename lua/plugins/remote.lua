-- lua/plugins/remote.lua
return {
    {
        'amitds1997/remote-nvim.nvim',
        version = '*',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'MunifTanjim/nui.nvim',
            'nvim-telescope/telescope.nvim',
        },
        config = function()
            require('remote-nvim').setup({
                remote = {
                    copy_dirs = {
                        config = {
                            compression = {
                                enabled = true,
                                additional_opts = {
                                    '--exclude=.git',
                                    '--exclude=.gitignore',
                                    '--exclude=.github',
                                    '--exclude=docs',
                                    '--exclude=lazy-lock.json',
                                    '--exclude=lazyvim.json',
                                    '--exclude=node_modules',
                                    '--exclude=.cache',
                                },
                            },
                        },
                        data = {
                            base = vim.fn.stdpath('data'),
                            dirs = {}, -- ← НИЧЕГО из data не копируем
                            compression = { enabled = true },
                        },
                    },
                },
            })
        end,
    },
}
