---@type integer
local nproc = #vim.uv.cpu_info()

---@type LazyPluginSpec[]
return {
    {
        'dchinmay2/clangd_extensions.nvim',
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
                        '--enable-config',
                        '--limit-references=200',
                        '--limit-results=30',
                        '-j=' .. tostring(nproc),
                    },
                    init_options = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },
                },
            },
            setup = {
                ---@return boolean|nil
                clangd = function()
                    require('clangd_extensions').setup()
                end,
            },
        },
    },
}
