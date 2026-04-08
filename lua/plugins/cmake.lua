---@type string[][] -- { suffix, command, label }
local mappings = {
    { 'g', 'CMakeGenerate', 'Generate' },
    { 'b', 'CMakeBuild', 'Build' },
    { 'r', 'CMakeRun', 'Run' },
    { 'd', 'CMakeDebug', 'Debug' },
    { 'c', 'CMakeClean', 'Clean' },
    { 'x', 'CMakeStop', 'Stop' },
    { 'p', 'CMakeSelectConfigurePreset', 'Configure Preset' },
    { 'P', 'CMakeSelectBuildPreset', 'Build Preset' },
    { 't', 'CMakeSelectBuildTarget', 'Build Target' },
    { 'l', 'CMakeSelectLaunchTarget', 'Launch Target' },
    { 'v', 'CMakeSelectBuildType', 'Variant' },
    { 'k', 'CMakeSelectKit', 'Kit' },
    { 'o', 'CMakeOpen', 'Open Runner' },
    { 'q', 'CMakeClose', 'Close Runner' },
    { 's', 'CMakeSettings', 'Settings' },
}

---@type LazyKeysSpec[]
local keys = vim.iter(mappings)
    :map(function(m)
        ---@type LazyKeysSpec
        return {
            '<leader>ck' .. m[1],
            '<cmd>' .. m[2] .. '<cr>',
            desc = 'CMake: ' .. m[3],
        }
    end)
    :totable()

---@type LazyPluginSpec[]
return {
    {
        'Civitasv/cmake-tools.nvim',
        keys = keys,
        opts = {},
    },
    {
        'folke/which-key.nvim',
        opts = {
            spec = {
                {
                    '<leader>ck',
                    group = 'CMake',
                    icon = { icon = '⚙', color = 'cyan' },
                },
            },
        },
    },
}
