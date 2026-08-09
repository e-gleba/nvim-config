-- lhs -> { command, label } for the 5 hub commands with default shortcuts.
-- https://github.com/iamironz/android-nvim-plugin/blob/main/docs/reference/keymaps.md
local hub = {
    { '<leader>am', 'AndroidMenu', 'Menu' },
    { '<leader>at', 'AndroidTargets', 'Targets' },
    { '<leader>ao', 'AndroidTools', 'Tools' },
    { '<leader>aa', 'AndroidActions', 'Actions' },
    { '<leader>ab', 'AndroidBuild', 'Build' },
}

---@type LazyKeysSpec[]
local keys = vim.iter(hub)
    :map(function(k)
        return { k[1], '<cmd>' .. k[2] .. '<cr>', desc = 'Android: ' .. k[3] }
    end)
    :totable()

---@type LazyPluginSpec[]
return {
    {
        -- IDE-level Android/iOS/KMP/JVM workflows in Neovim: build, deploy,
        -- logcat, device management, Gradle task browser, run configs.
        -- https://github.com/iamironz/android-nvim-plugin
        'iamironz/android-nvim-plugin',
        name = 'android',
        main = 'android', -- lets lazy.nvim auto-call require('android').setup(opts)

        -- Only register in an Android/Gradle/iOS workspace. vim.fs.root (0.10+)
        -- searches upward from the current file and falls back to cwd for
        -- unnamed buffers — replacing the old manual marker loop.
        cond = function()
            return vim.fs.root(0, {
                'settings.gradle',
                'settings.gradle.kts',
                'build.gradle',
                'build.gradle.kts',
                'AndroidManifest.xml',
                'gradlew',
                '.android.nvim.json',
            }) ~= nil
        end,

        -- Load on first Android command, or when opening Gradle-ecosystem files.
        -- Mirrors upstream's documented 13-command surface (5 hub + 8 direct).
        cmd = {
            'AndroidMenu',
            'AndroidTargets',
            'AndroidTools',
            'AndroidActions',
            'AndroidBuild',
            'AndroidRun',
            'AndroidRunStop',
            'AndroidLogcat',
            'AndroidBuildPrompt',
            'AndroidBuildAssemble',
            'AndroidGradleTasks',
            'AndroidIOSBuild',
            'AndroidIOSDeploy',
        },
        ft = { 'java', 'kotlin', 'groovy' },
        keys = keys,

        ---@type android.Opts
        opts = {
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
            -- Disabled: lazy.nvim owns the default shortcuts (see `keys`).
            keymaps = { enabled = false },
        },
    },
}
