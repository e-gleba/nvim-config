---@type LazyPluginSpec[]
return {
    {
        'Civitasv/cmake-tools.nvim',
        ---@type CMakeToolsSettings
        opts = {
            cmake_soft_link_compile_commands = true,
            cmake_compile_commands_from_lsp = false,
            cmake_executor = {
                name = 'quickfix',
                opts = { show = 'only_on_error' },
            },
            cmake_runner = {
                name = 'toggleterm',
                opts = { direction = 'horizontal', close_on_exit = false },
            },
        },
        keys = {
            -- generate / build / run
            {
                '<leader>cg',
                '<cmd>CMakeGenerate<cr>',
                desc = 'cmake generate',
            },
            {
                '<leader>cb',
                '<cmd>CMakeBuild<cr>',
                desc = 'cmake build',
            },
            {
                '<leader>cr',
                '<cmd>CMakeRun<cr>',
                desc = 'cmake run',
            },
            {
                '<leader>cd',
                '<cmd>CMakeDebug<cr>',
                desc = 'cmake debug',
            },
            {
                '<leader>cc',
                '<cmd>CMakeClean<cr>',
                desc = 'cmake clean',
            },
            {
                '<leader>cx',
                '<cmd>CMakeStop<cr>',
                desc = 'cmake stop',
            },

            -- presets & targets
            {
                '<leader>cp',
                '<cmd>CMakeSelectConfigurePreset<cr>',
                desc = 'cmake configure preset',
            },
            {
                '<leader>cP',
                '<cmd>CMakeSelectBuildPreset<cr>',
                desc = 'cmake build preset',
            },
            {
                '<leader>ct',
                '<cmd>CMakeSelectBuildTarget<cr>',
                desc = 'cmake build target',
            },
            {
                '<leader>cl',
                '<cmd>CMakeSelectLaunchTarget<cr>',
                desc = 'cmake launch target',
            },
            {
                '<leader>cv',
                '<cmd>CMakeSelectBuildType<cr>',
                desc = 'cmake variant (Debug/Release)',
            },
            {
                '<leader>ck',
                '<cmd>CMakeSelectKit<cr>',
                desc = 'cmake kit (compiler)',
            },

            -- quick access
            {
                '<leader>co',
                '<cmd>CMakeOpen<cr>',
                desc = 'cmake open runner',
            },
            {
                '<leader>cq',
                '<cmd>CMakeClose<cr>',
                desc = 'cmake close runner',
            },
            {
                '<leader>cs',
                '<cmd>CMakeSettings<cr>',
                desc = 'cmake settings',
            },
        },
    },
}
