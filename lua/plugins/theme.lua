return {
    -- 1. Configure the Tokyonight plugin to use the "day" style
    {
        'folke/tokyonight.nvim',
        lazy = false,
        priority = 1000,
        opts = {
            style = 'day', -- This enforces the light variant
        },
    },
}
