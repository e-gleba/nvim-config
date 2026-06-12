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
        cmd = {
            'AndroidMenu',
            'AndroidRun',
            'AndroidRunStop',
            'AndroidBuild',
            'AndroidBuildPrompt',
            'AndroidBuildAssemble',
            'AndroidLogcat',
            'AndroidStop',
            'AndroidSelectDevice',
            'AndroidSelectModule',
            'AndroidTargets',
            'AndroidTools',
            'AndroidActions',
            'AndroidGradleTasks',
            'AndroidIOSBuild',
            'AndroidIOSDeploy',
        },
        ft = { 'java', 'kotlin', 'groovy' },

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
            -- Disable upstream keymaps so lazy.nvim owns them (see `keys`).
            keymaps = { enabled = false },
        },
    },
}
