---@type LazyPluginSpec[]
return {
    {
        'p00f/clangd_extensions.nvim',
        lazy = true,
        opts = {
            memory_usage = { border = 'rounded' },
            symbol_info = { border = 'rounded' },
        },
    },
    {
        'neovim/nvim-lspconfig',
        opts = {
            servers = {
                clangd = {
                    cmd = {
                        'clangd',
                        '--background-index',
                        '--clang-tidy',
                        '--header-insertion=iwyu',
                        '--completion-style=detailed',
                        '--function-arg-placeholders',
                        '--fallback-style=llvm',
                        '--pch-storage=memory',
                        '--all-scopes-completion',
                        '--header-insertion-decorators',
                        '--limit-references=200',
                        '--limit-results=30',
                        '-j=' .. tostring(#vim.uv.cpu_info()),
                    },
                    init_options = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },
                },
            },
        },
    },
}
