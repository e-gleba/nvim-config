---@type string[]
local config_files = {
    '.cmake-format',
    '.cmake-format.py',
    '.cmake-format.yaml',
    '.cmake-format.json',
    'CMakeLists.txt',
}

---@type LazyPluginSpec[]
return {
    {
        'stevearc/conform.nvim',
        ---@type conform.setupOpts
        opts = {
            formatters_by_ft = {
                cmake = { 'cmake_format' },
            },
            ---@type table<string, conform.FormatterConfigOverride>
            formatters = {
                cmake_format = {
                    ---@type string[]
                    prepend_args = {
                        '--line-width',
                        '80',
                        '--tab-size',
                        '4',
                        '--use-tabchars',
                        'false',
                        '--max-subgroups-hwrap',
                        '3',
                        '--max-pargs-hwrap',
                        '6',
                        '--dangle-parens',
                        'true',
                    },
                    ---@param self conform.FormatterConfig
                    ---@param ctx conform.Context
                    ---@return string|nil
                    cwd = function(self, ctx)
                        return require('conform.util').root_file(config_files)(
                            self,
                            ctx
                        )
                    end,
                    require_cwd = false,
                },
            },
        },
    },
    {
        'mason-org/mason.nvim',
        ---@param opts MasonSettings | { ensure_installed?: string[] }
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { 'cmakelang' })
        end,
    },
}
