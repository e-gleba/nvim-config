---@type LazyPluginSpec[]
return {
    {
        'Civitasv/cmake-tools.nvim',
        keys = {
            {
                '<leader>ckg',
                '<cmd>CMakeGenerate<cr>',
                desc = 'cmake generate',
            },
            {
                '<leader>ckb',
                '<cmd>CMakeBuild<cr>',
                desc = 'cmake build',
            },
            {
                '<leader>ckr',
                '<cmd>CMakeRun<cr>',
                desc = 'cmake run',
            },
            {
                '<leader>ckd',
                '<cmd>CMakeDebug<cr>',
                desc = 'cmake debug',
            },
            {
                '<leader>ckc',
                '<cmd>CMakeClean<cr>',
                desc = 'cmake clean',
            },
            {
                '<leader>ckx',
                '<cmd>CMakeStop<cr>',
                desc = 'cmake stop',
            },
            {
                '<leader>ckp',
                '<cmd>CMakeSelectConfigurePreset<cr>',
                desc = 'cmake configure preset',
            },
            {
                '<leader>ckP',
                '<cmd>CMakeSelectBuildPreset<cr>',
                desc = 'cmake build preset',
            },
            {
                '<leader>ckt',
                '<cmd>CMakeSelectBuildTarget<cr>',
                desc = 'cmake build target',
            },
            {
                '<leader>ckl',
                '<cmd>CMakeSelectLaunchTarget<cr>',
                desc = 'cmake launch target',
            },
            {
                '<leader>ckv',
                '<cmd>CMakeSelectBuildType<cr>',
                desc = 'cmake variant',
            },
            {
                '<leader>ckk',
                '<cmd>CMakeSelectKit<cr>',
                desc = 'cmake kit',
            },
            {
                '<leader>cko',
                '<cmd>CMakeOpen<cr>',
                desc = 'cmake open runner',
            },
            {
                '<leader>ckq',
                '<cmd>CMakeClose<cr>',
                desc = 'cmake close runner',
            },
            {
                '<leader>cks',
                '<cmd>CMakeSettings<cr>',
                desc = 'cmake settings',
            },
        },
    },
    {
        'folke/which-key.nvim',
        opts = {
            spec = {
                { '<leader>c', group = 'code' },
                {
                    '<leader>ck',
                    group = 'CMake',
                    icon = { icon = '⚙', color = 'cyan' },
                },
            },
        },
    },
}
