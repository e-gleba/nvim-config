---@type LazyPluginSpec[]
return {
    {
        -- android-nvim-plugin provides IDE-level Android and iOS workflows inside Neovim:
        -- build, deploy, logcat, device management, Gradle task browser, and run configs.
        -- It auto-detects project type (Android, iOS, KMP, JVM) so the same plugin works
        -- across mobile stacks. We only load it when Android/Gradle project markers exist.
        -- https://github.com/iamironz/android-nvim-plugin
        "iamironz/android-nvim-plugin",
        name = "android",
        -- Only register this plugin spec when inside an Android/Gradle/iOS workspace.
        -- This keeps keymaps, commands, and filetype hooks completely hidden in pure
        -- desktop C++ projects. If you :cd into an Android project after startup,
        -- restart Neovim from that directory for the plugin to register.
        cond = function()
            local markers = {
                "build.gradle",
                "build.gradle.kts",
                "settings.gradle",
                "settings.gradle.kts",
                "AndroidManifest.xml",
                "gradlew",
                ".android.nvim.json",
            }
            -- Search upward from current working directory
            for _, marker in ipairs(markers) do
                if vim.fn.findfile(marker, ".;") ~= "" then
                    return true
                end
            end
            -- Search upward from the current file's directory (for `nvim path/to/file` outside project root)
            local bufname = vim.api.nvim_buf_get_name(0)
            if bufname ~= "" then
                local dir = vim.fn.fnamemodify(bufname, ":h")
                for _, marker in ipairs(markers) do
                    if vim.fn.findfile(marker, dir .. ";") ~= "" then
                        return true
                    end
                end
            end
            return false
        end,
        -- Lazy-load on first Android command invocation; cond must pass first
        cmd = {
            "AndroidMenu",
            "AndroidRun",
            "AndroidRunStop",
            "AndroidBuild",
            "AndroidBuildPrompt",
            "AndroidBuildAssemble",
            "AndroidLogcat",
            "AndroidStop",
            "AndroidSelectDevice",
            "AndroidSelectModule",
            "AndroidTargets",
            "AndroidTools",
            "AndroidActions",
            "AndroidGradleTasks",
            "AndroidIOSBuild",
            "AndroidIOSDeploy",
        },
        -- Also load when opening Gradle-ecosystem source files
        ft = { "java", "kotlin", "groovy" },
        ---@type android.Opts
        opts = {
            -- Use upstream defaults; only disable built-in keymaps so Lazy.nvim owns them.
            -- Default upstream config:
            -- https://github.com/iamironz/android-nvim-plugin/blob/main/lua/android/config.lua
            sdk = {
                root_env_keys = { "ANDROID_SDK_ROOT", "ANDROID_HOME" },
                local_properties = true,
            },
            run = {
                module_preference = { ":androidApp", ":app" },
            },
            ui = {
                file_watcher = true,
                autosave = true,
                restore_logcat = true,
            },
            keymaps = {
                enabled = false,
            },
        },
        config = function(_, opts)
            require("android").setup(opts)
        end,
        keys = {
            {
                "<leader>am",
                "<cmd>AndroidMenu<cr>",
                desc = "Android: Menu",
            },
            {
                "<leader>ab",
                "<cmd>AndroidBuild<cr>",
                desc = "Android: Build",
            },
            {
                "<leader>ar",
                "<cmd>AndroidRun<cr>",
                desc = "Android: Run",
            },
            {
                "<leader>ad",
                "<cmd>AndroidSelectDevice<cr>",
                desc = "Android: Device",
            },
            {
                "<leader>aM",
                "<cmd>AndroidSelectModule<cr>",
                desc = "Android: Module",
            },
            {
                "<leader>al",
                "<cmd>AndroidLogcat<cr>",
                desc = "Android: Logcat",
            },
            {
                "<leader>ax",
                "<cmd>AndroidStop<cr>",
                desc = "Android: Stop",
            },
        },
    },
    {
        "folke/which-key.nvim",
        optional = true,
        opts = {
            spec = {
                {
                    "<leader>a",
                    group = "Android",
                    icon = { icon = "", color = "green" },
                },
            },
        },
    },
}
