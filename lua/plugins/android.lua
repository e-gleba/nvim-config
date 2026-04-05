-- android-nvim — Android development integration for Neovim.
-- lua/plugins/android.lua

-------------------------------------------------------------------------------
-- Types (LuaLS edit-time schema)
-------------------------------------------------------------------------------

-- SDK discovery. Priority: root → env keys → local.properties → candidates.
---@class android.SdkOpts
---@field root?                   string
---@field root_env_keys           string[]
---@field local_properties        boolean
---@field local_properties_paths  string[]
---@field root_candidates         string[]

---@class android.RunAllOpts
---@field order           string[]
---@field target_modules  table<string, string[]>

---@class android.RunOpts
---@field config_path        string
---@field default_module?    string
---@field module_preference  string[]
---@field run_all            android.RunAllOpts

---@class android.BuildOpts
---@field gradle_command?        string[]
---@field scan_all_apk_outputs   boolean

---@class android.UiOpts
---@field file_watcher     boolean
---@field autosave         boolean
---@field restore_logcat   boolean

---@class android.KeymapOpts
---@field enabled?  boolean

---@class android.Opts
---@field sdk      android.SdkOpts
---@field run      android.RunOpts
---@field build    android.BuildOpts
---@field ui       android.UiOpts
---@field keymaps  android.KeymapOpts

-------------------------------------------------------------------------------
-- Runtime schema validation (vim.validate)
-------------------------------------------------------------------------------

--- Validates the merged opts table at startup.
--- Throws a clear error pointing at the exact misconfigured field.
---@param o android.Opts
local function validate(o)
    -- Top-level sections must be tables.
    vim.validate('opts.sdk', o.sdk, 'table')
    vim.validate('opts.run', o.run, 'table')
    vim.validate('opts.build', o.build, 'table')
    vim.validate('opts.ui', o.ui, 'table')
    vim.validate('opts.keymaps', o.keymaps, 'table')

    -- sdk
    vim.validate('sdk.root', o.sdk.root, 'string', true)
    vim.validate('sdk.root_env_keys', o.sdk.root_env_keys, 'table')
    vim.validate('sdk.local_properties', o.sdk.local_properties, 'boolean')
    vim.validate(
        'sdk.local_properties_paths',
        o.sdk.local_properties_paths,
        'table'
    )
    vim.validate('sdk.root_candidates', o.sdk.root_candidates, 'table')

    -- run
    vim.validate('run.config_path', o.run.config_path, 'string')
    vim.validate('run.default_module', o.run.default_module, 'string', true)
    vim.validate('run.module_preference', o.run.module_preference, 'table')
    vim.validate('run.run_all', o.run.run_all, 'table')
    vim.validate('run.run_all.order', o.run.run_all.order, 'table')
    vim.validate(
        'run.run_all.target_modules',
        o.run.run_all.target_modules,
        'table'
    )

    -- build
    vim.validate('build.gradle_command', o.build.gradle_command, 'table', true)
    vim.validate(
        'build.scan_all_apk_outputs',
        o.build.scan_all_apk_outputs,
        'boolean'
    )

    -- ui
    vim.validate('ui.file_watcher', o.ui.file_watcher, 'boolean')
    vim.validate('ui.autosave', o.ui.autosave, 'boolean')
    vim.validate('ui.restore_logcat', o.ui.restore_logcat, 'boolean')

    -- keymaps
    vim.validate('keymaps.enabled', o.keymaps.enabled, 'boolean', true)
end

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local home = vim.env.HOME or vim.fn.expand('~')
local localappdata = vim.env.LOCALAPPDATA or ''
local appdata = vim.env.APPDATA or ''
local join = vim.fs.joinpath

-------------------------------------------------------------------------------
-- Spec
-------------------------------------------------------------------------------

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
        -- Runtime validation gate. Throws immediately on bad config.
        validate(opts)
        require('android').setup(opts)
    end,
}
