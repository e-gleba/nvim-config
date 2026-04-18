---@type LazyPluginSpec[]
return {
    {
        'iamironz/android-nvim-plugin',
        lazy = true,
        config = function()
            ---@type android.Opts
            require('android').setup({
                sdk = {
                    root_env_keys = { 'ANDROID_SDK_ROOT', 'ANDROID_HOME' },
                    local_properties = true,
                },
                run = {
                    module_preference = { ':androidApp', ':app' },
                },
                ui = {
                    file_watcher = true,
                    autosave = true,
                    restore_logcat = true,
                },
            })
        end,
        keys = {
            {
                '<leader>ar',
                '<cmd>AndroidRun<cr>',
                desc = 'Android: Run',
            },
            {
                '<leader>ab',
                '<cmd>AndroidBuild<cr>',
                desc = 'Android: Build',
            },
            {
                '<leader>ad',
                '<cmd>AndroidSelectDevice<cr>',
                desc = 'Android: Device',
            },
            {
                '<leader>am',
                '<cmd>AndroidSelectModule<cr>',
                desc = 'Android: Module',
            },
            {
                '<leader>al',
                '<cmd>AndroidLogcat<cr>',
                desc = 'Android: Logcat',
            },
            {
                '<leader>ax',
                '<cmd>AndroidStop<cr>',
                desc = 'Android: Stop',
            },
        },
    },
    {
        'folke/which-key.nvim',
        opts = {
            spec = {
                {
                    '<leader>a',
                    group = 'Android',
                    icon = { icon = '', color = 'green' },
                },
            },
        },
    },
}
