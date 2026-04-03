---@module 'lazyvim'
-- Commands reference (no keymaps configured):
-- :AndroidMenu          — main hub                  (<leader>am default, disabled below)
-- :AndroidTargets       — build variants hub         (<leader>at)
-- :AndroidTools         — device manager / ADB hub   (<leader>ao)
-- :AndroidActions       — actions hub                (<leader>aa)
-- :AndroidBuild         — build with saved defaults  (<leader>ab)
-- :AndroidRun           — run current config
-- :AndroidRunStop       — stop active run jobs
-- :AndroidLogcat        — open logcat dock
-- :AndroidBuildPrompt   — build with module/variant prompts
-- :AndroidBuildAssemble — build only, no deploy
-- :AndroidGradleTasks   — Gradle task picker
-- :AndroidIOSBuild      — iOS build (xcodebuild)
-- :AndroidIOSDeploy     — iOS deploy (simulator / device)
-- :checkhealth android  — validate SDK, adb, Gradle, iOS tools

--- @class AndroidSdkOpts
--- @field root?                   string   SDK root override (nil = auto-discover)
--- @field root_env_keys?          string[] Env vars to check in order
--- @field local_properties?       boolean  Parse local.properties
--- @field local_properties_paths? string[] Paths to local.properties files
--- @field root_candidates?        string[] Fallback paths when env vars absent

--- @class AndroidRunAllOpts
--- @field order?          string[]           Target execution order
--- @field target_modules? table<string, string[]> Preferred modules per target type

--- @class AndroidRunOpts
--- @field config_path?      string         Workspace-relative JSON run config path
--- @field default_module?   string         Force module (e.g. ":app")
--- @field module_preference? string[]      Preferred modules when multiple detected
--- @field run_all?          AndroidRunAllOpts

--- @class AndroidBuildOpts
--- @field gradle_command?       string|string[] Override gradlew command / extra args
--- @field scan_all_apk_outputs? boolean         Recursive APK scan fallback

--- @class AndroidUIopts
--- @field file_watcher?   boolean
--- @field autosave?       boolean
--- @field restore_logcat? boolean

--- @class AndroidKeymapMappings
--- @field menu?    string|false
--- @field targets? string|false
--- @field tools?   string|false
--- @field actions? string|false
--- @field build?   string|false

--- @class AndroidKeymapOpts
--- @field enabled?  boolean
--- @field mappings? AndroidKeymapMappings

--- @class AndroidOpts
--- @field sdk?      AndroidSdkOpts
--- @field run?      AndroidRunOpts
--- @field build?    AndroidBuildOpts
--- @field ui?       AndroidUIopts
--- @field keymaps?  AndroidKeymapOpts

---@type LazyPluginSpec[]
return {
    'iamironz/android-nvim-plugin',
    lazy = false, -- required: file watcher + restore_logcat fire at startup

    --- @type AndroidOpts
    opts = {
        sdk = {
            root = nil,
            root_env_keys = { 'ANDROID_SDK_ROOT', 'ANDROID_HOME' },
            local_properties = true,
            local_properties_paths = { 'local.properties' },
            -- universal fallbacks: Scoop, LOCALAPPDATA, standard Linux/macOS paths
            root_candidates = {
                -- Windows: Scoop
                vim.fn.expand('~/scoop/apps/android-sdk/current'),
                -- Windows: AppData (Android Studio install)
                (os.getenv('LOCALAPPDATA') or '') .. '/Android/Sdk',
                -- Windows: ProgramData fallback
                (os.getenv('APPDATA') or '') .. '/Android/Sdk',
                -- macOS: Android Studio default
                vim.fn.expand('~/Library/Android/sdk'),
                -- Linux: Android Studio default
                vim.fn.expand('~/Android/Sdk'),
                -- Linux: manual / sdkmanager default
                vim.fn.expand('~/android-sdk'),
                vim.fn.expand('/opt/android-sdk'),
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
            gradle_command = nil, -- e.g. { "./gradlew", "--no-daemon" }
            scan_all_apk_outputs = false,
        },

        ui = {
            file_watcher = true,
            autosave = true,
            restore_logcat = true,
        },

        keymaps = {
            --- enabled = false, -- all keymaps disabled; use commands directly
        },
    },

    config = function(_, opts)
        require('android').setup(opts)
    end,
}
