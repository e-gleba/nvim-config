-- Scale clangd workers with the machine: half the logical cores, clamped to
-- [2, 8]. Workstations index fast; laptops stay cool and responsive.
local cores = vim.uv.available_parallelism()
local jobs = math.max(2, math.min(8, math.floor(cores / 2)))

---@type LazyPluginSpec[]
return {
    -- Disable the unmaintained p00f fork bundled by LazyVim's `lang.clangd` extra.
    -- https://github.com/p00f/clangd_extensions.nvim
    { 'https://github.com/p00f/clangd_extensions.nvim.git', enabled = false },

    -- clangd_extensions.nvim exposes clangd-specific LSP extensions that are not
    -- part of the standard LSP spec: AST viewer, type hierarchy, symbol info,
    -- memory usage, source/header switch, and completion-score boosting for
    -- nvim-cmp. The dchinmay2 fork is actively maintained and requires Neovim 0.10+.
    -- https://github.com/dchinmay2/clangd_extensions.nvim
    -- https://sr.ht/~chinmay/clangd_extensions.nvim/
    {
        'https://github.com/dchinmay2/clangd_extensions.nvim.git',
        name = 'clangd_extensions.nvim',
        ft = { 'c', 'cpp', 'objc', 'objcpp' },
        opts = {
            ast = {
                role_icons = {
                    type = '',
                    declaration = '',
                    expression = '',
                    specifier = '',
                    statement = '',
                    ['template argument'] = '',
                },
                kind_icons = {
                    compound = '',
                    recovery = '',
                    translation_unit = '',
                    pack_expansion = '',
                    template_type_parm = '',
                    template_non_type_parm = '',
                    template_template_parm = '',
                    template_param_object = '',
                },
                highlights = {
                    detail = 'Comment',
                },
            },
            memory_usage = {
                border = 'rounded',
            },
            symbol_info = {
                border = 'rounded',
            },
        },
    },

    -- Hardened clangd server flags: a minimal, conservative set replacing the
    -- obsolete / crash-prone defaults bundled by LazyVim and most configs.
    -- Workers scale with the machine (`jobs` above); low priority keeps the
    -- background index polite on laptops.
    --
    -- Removed (do NOT add back):
    --  * --cross-file-rename       : obsolete since clangd 18+, init errors.
    --  * --experimental-modules-support : known crash trigger.
    --                                 https://github.com/clangd/clangd/issues/2392
    --  * --pch-storage=memory      : see above.
    --
    -- Windows: add --query-driver pointing at your real compiler so clangd can
    -- discover system includes. https://github.com/clangd/clangd/discussions/2489
    --   MinGW64: --query-driver=C:/msys64/mingw64/bin/g++.exe
    --   MSVC:    --query-driver=C:/Program Files/.../Hostx64/x64/cl.exe
    {
        'https://github.com/neovim/nvim-lspconfig.git',
        opts = {
            servers = {
                clangd = {
                    cmd = {
                        'clangd',
                        '--background-index',
                        '--background-index-priority=low',
                        '--clang-tidy',
                        '--header-insertion=iwyu',
                        '--header-insertion-decorators',
                        '--all-scopes-completion',
                        '--completion-style=detailed',
                        '--function-arg-placeholders',
                        '--fallback-style=llvm',
                        '--log=error',
                        '-j=' .. jobs,
                    },
                    init_options = {
                        clangdFileStatus = true,
                        usePlaceholders = true,
                        completeUnimported = true,
                        fallbackFlags = { '-std=c++23' },
                    },
                },
            },
        },
    },
}
