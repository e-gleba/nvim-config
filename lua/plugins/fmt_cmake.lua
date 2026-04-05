-- CMake Formatting — cmake_format via conform.nvim
-- https://github.com/stevearc/conform.nvim
-- https://github.com/cheshirekow/cmake_format (part of cmakelang)
--
-- Formatter: cmake_format (installed via Mason as `cmakelang` package)
-- Config:    .cmake-format  |  .cmake-format.py  |  .cmake-format.yaml
--            .cmake-format.json  |  pyproject.toml [cmake_format section]
--
-- When no project-level config is found, the `prepend_args` below act
-- as a sensible baseline. Once a config file exists, cmake_format reads
-- it automatically and the CLI args serve as overridable defaults.

-- Files cmake_format recognises as project-level configuration.
-- Used both for `cwd` resolution and documentation.
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
    -- conform.nvim — formatter engine
    -- https://github.com/stevearc/conform.nvim
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
                    -- Baseline args applied when no config file is present.
                    -- cmake_format merges CLI flags with config-file values;
                    -- config-file wins on conflict, so these are safe defaults.
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

                    -- Resolve working directory to the nearest ancestor containing
                    -- a cmake_format config or CMakeLists.txt. This ensures the
                    -- formatter picks up per-project settings correctly.
                    --
                    -- `root_file` returns a function(self, ctx) → string|nil,
                    -- so we wrap it to defer the `require` until first invocation.
                    ---@param self conform.FormatterConfig
                    ---@param ctx conform.Context
                    ---@return string|nil
                    cwd = function(self, ctx)
                        return require('conform.util').root_file(config_files)(
                            self,
                            ctx
                        )
                    end,

                    -- Format even when no config file / project root is found.
                    -- The prepend_args above provide a reasonable fallback.
                    require_cwd = false,
                },
            },
        },
    },

    -- Mason — ensure cmakelang is installed
    -- https://github.com/mason-org/mason.nvim
    --
    -- The `cmakelang` Mason package provides both:
    --   • cmake-format  (formatter)
    --   • cmake-lint    (linter, usable via nvim-lint if desired)
    {
        'mason-org/mason.nvim',
        ---@param opts MasonSettings | { ensure_installed?: string[] }
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { 'cmakelang' })
        end,
    },
}
