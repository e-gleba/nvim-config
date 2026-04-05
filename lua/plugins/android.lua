-- android-nvim — Android development integration for Neovim.
-- lua/plugins/android.lua

local home = vim.env.HOME or vim.fn.expand('~')
local localappdata = vim.env.LOCALAPPDATA or ''
local appdata = vim.env.APPDATA or ''
local join = vim.fs.joinpath

---@type LazyPluginSpec
return {
    'iamironz/android-nvim-plugin',

    -- Not lazy: file watcher and logcat restore fire at startup.
    lazy = false,

    ---@type android.Opts
    opts = {

        sdk = {
            root = nil,
            root_env_keys = { 'ANDROID_SDK_ROOT', 'ANDROID_HOME' },
            local_properties = true,
            local_properties_paths = { 'local.properties' },
            root_candidates = {
                join(home, 'scoop', 'apps', 'android-clt', 'current'),
                join(localappdata, 'Android', 'Sdk'),
                join(appdata, 'Android', 'Sdk'),
                join(home, 'Library', 'Android', 'sdk'),
                join(home, 'Android', 'Sdk'),
                join(home, 'android-sdk'),
                '/opt/android-sdk',
            },
        },

        run = {
            config_path = '.android.nvim.json',
            default_module = nil,
            module_preference = { ':androidApp', ':app' },
            run_all = {
                order = { 'jvm', 'android', 'ios' },
                target_modules = {
                    jvm = { ':server' },
                    android = { ':androidApp', ':app' },
                },
            },
        },

        build = {
            gradle_command = nil,
            scan_all_apk_outputs = false,
        },

        ui = {
            file_watcher = true,
            autosave = true,
            restore_logcat = true,
        },

        keymaps = {},
    },

    config = function(_, opts)
        require('android').setup(opts)
    end,
}
