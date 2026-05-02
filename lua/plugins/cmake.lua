-- Professional CMake IDE integration via Civitasv/cmake-tools.nvim.
-- Comparable to vscode-cmake-tools; auto-detects CMake projects and
-- provides generate, build, preset selection, debug launch and compile
-- commands auto-linking for clangd.
--
-- Refs:
--   https://github.com/Civitasv/cmake-tools.nvim
--   https://github.com/Civitasv/cmake-tools.nvim/blob/main/docs/cmake_presets.md
--   https://github.com/Civitasv/cmake-tools.nvim/blob/main/docs/howto.md

---Detect whether the current cwd or file lives inside a CMake project.
---@return boolean
local function is_cmake_project()
    local markers = { 'CMakeLists.txt', 'CMakePresets.json' }
    local paths = { vim.loop.cwd(), vim.fn.expand('%:p:h') }
    for _, base in ipairs(paths) do
        local dir = base
        while
            dir
            and dir ~= '/'
            and dir ~= ''
            and not dir:match('^%a:[/\\]?$')
        do
            for _, marker in ipairs(markers) do
                local ok, stat = pcall(vim.loop.fs_stat, dir .. '/' .. marker)
                if ok and stat then
                    return true
                end
            end
            dir = vim.fn.fnamemodify(dir, ':h')
        end
    end
    return false
end

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
        cond = is_cmake_project,
        cmd = {
            'CMakeGenerate',
            'CMakeBuild',
            'CMakeRun',
            'CMakeDebug',
            'CMakeClean',
            'CMakeStop',
            'CMakeSelectConfigurePreset',
            'CMakeSelectBuildPreset',
            'CMakeSelectBuildTarget',
            'CMakeSelectLaunchTarget',
            'CMakeSelectBuildType',
            'CMakeSelectKit',
            'CMakeOpen',
            'CMakeClose',
            'CMakeSettings',
            'CMakeTest',
            'CMakeShowTargetFiles',
            'CMakeQuickBuild',
            'CMakeCopyCompileCommands',
        },
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
