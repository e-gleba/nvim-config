-- cmake-tools.nvim :: Professional CMake IDE integration for Neovim.
-- Comparable to vscode-cmake-tools; auto-detects CMake projects and provides
-- generate, build, preset selection, debug launch, and compile_commands
-- auto-linking for clangd.
--
-- Plugin:  https://github.com/Civitasv/cmake-tools.nvim
-- Presets: https://github.com/Civitasv/cmake-tools.nvim/blob/main/docs/cmake_presets.md
-- Howto:   https://github.com/Civitasv/cmake-tools.nvim/blob/main/docs/howto.md
-- Issues:  https://github.com/Civitasv/cmake-tools.nvim/issues

---@class CMakeMapping
---@field [1] string suffix
---@field [2] string command
---@field [3] string label

---@type CMakeMapping[]
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
    { 'T', 'CMakeTest', 'CTest' },
    { 'f', 'CMakeShowTargetFiles', 'Target Files' },
}

---@type LazyKeysSpec[]
local keys = vim.iter(mappings)
    :map(function(m)
        return {
            '<leader>ck' .. m[1],
            '<cmd>' .. m[2] .. '<cr>',
            desc = 'CMake: ' .. m[3],
        }
    end)
    :totable()

---@type string[]
local commands = vim.iter(mappings)
    :map(function(m)
        return m[2]
    end)
    :totable()

---@type LazyPluginSpec[]
return {
    {
        'https://github.com/Civitasv/cmake-tools.nvim.git',
        ft = { 'cmake', 'c', 'cpp', 'objc', 'objcpp' },
        cmd = commands,
        keys = keys,
        dependencies = { 'https://github.com/nvim-lua/plenary.nvim.git' },
        opts = {
            cmake_command = 'cmake',
            cmake_use_preset = true,
            cmake_regenerate_on_save = true,
            cmake_compile_commands_options = {
                action = 'soft_link',
                target = vim.uv.cwd(),
            },
            cmake_virtual_text_support = true,
            cmake_dap_configuration = {
                name = 'cpp',
                type = 'codelldb',
                request = 'launch',
                stopOnEntry = false,
                runInTerminal = true,
                console = 'integratedTerminal',
            },
        },
    },
    {
        'https://github.com/folke/which-key.nvim.git',
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
