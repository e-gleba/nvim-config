-- Professional CMake IDE integration via Civitasv/cmake-tools.nvim.
-- Comparable to vscode-cmake-tools; auto-detects CMake projects and
-- provides generate, build, preset selection, debug launch and compile
-- commands auto-linking for clangd.
--
-- Refs:
--   https://github.com/Civitasv/cmake-tools.nvim
--   https://github.com/Civitasv/cmake-tools.nvim/blob/main/docs/cmake_presets.md
--   https://github.com/Civitasv/cmake-tools.nvim/blob/main/docs/howto.md

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

---@type LazyPluginSpec[]
return {
    {
        'Civitasv/cmake-tools.nvim',
        ft = 'cmake',
        keys = keys,
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            cmake_use_preset = true,
            cmake_regenerate_on_save = true,
            cmake_compile_commands_options = {
                action = 'soft_link',
                target = vim.loop.cwd,
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
