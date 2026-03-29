-- lua/plugins/cmake_format.lua

---@type LazyPluginSpec[]
return {
    {
        'stevearc/conform.nvim',
        dependencies = { 'mason.nvim' },
        ---@type conform.setupOpts
        opts = {
            formatters_by_ft = {
                cmake = { 'cmake_format' },
            },
            ---@type table<string, conform.FormatterConfigOverride>
            formatters = {
                cmake_format = {
                    prepend_args = { '--line-width', '80' },
                    cwd = function(_, ctx)
                        return require('conform.util').root_file({
                            '.cmake-format',
                            '.cmake-format.py',
                            '.cmake-format.yaml',
                            '.cmake-format.json',
                            'CMakeLists.txt',
                        })(_, ctx)
                    end,
                    require_cwd = false,
                },
            },
        },
    },
    {
        'mason-org/mason.nvim',
        ---@param opts MasonSettings|{ensure_installed?: string[]}
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { 'cmakelang' })
        end,
    },
}
