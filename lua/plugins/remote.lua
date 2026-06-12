-- remote-nvim.nvim :: Develop inside remote containers/SSH/Docker from Neovim.
-- https://github.com/amitds1997/remote-nvim.nvim

---@type LazyPluginSpec[]
return {
    {
        'https://github.com/amitds1997/remote-nvim.nvim.git',
        version = '*',
        dependencies = {
            'https://github.com/nvim-lua/plenary.nvim.git',
            'https://github.com/MunifTanjim/nui.nvim.git',
            'https://github.com/nvim-telescope/telescope.nvim.git',
        },
        cmd = {
            'RemoteStart',
            'RemoteStop',
            'RemoteInfo',
            'RemoteCleanup',
            'RemoteLog',
            'RemoteConfigDel',
            'RemoteSavedSessions',
        },
        keys = {
            {
                '<leader>Rr',
                '<cmd>RemoteStart<cr>',
                desc = 'Remote: start session',
            },
            {
                '<leader>Rs',
                '<cmd>RemoteStop<cr>',
                desc = 'Remote: stop session',
            },
            { '<leader>Ri', '<cmd>RemoteInfo<cr>', desc = 'Remote: info' },
            {
                '<leader>Rc',
                '<cmd>RemoteCleanup<cr>',
                desc = 'Remote: cleanup',
            },
            {
                '<leader>RS',
                '<cmd>RemoteSavedSessions<cr>',
                desc = 'Remote: saved sessions',
            },
        },
        opts = {
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
                                '--exclude=node_modules',
                                '--exclude=.cache',
                            },
                        },
                    },
                    data = {
                        base = vim.fn.stdpath('data'),
                        dirs = {}, -- nothing from data is copied
                        compression = { enabled = true },
                    },
                },
            },
        },
    },
}
