return {
    {
        'stevearc/conform.nvim',
        dependencies = { 'mason.nvim' },
        opts = {
            formatters_by_ft = {
                cmake = { 'cmake_format' },
            },
        },
    },

    {
        'mason-org/mason.nvim',
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { 'cmakelang' }) -- provides cmake-format
        end,
    },
}
