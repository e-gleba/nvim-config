---@type LazyPluginSpec[]
return {
    {
        'folke/snacks.nvim',

        -- Global kill switch — set before plugin loads via `init`.
        -- Disables all animation frames across every snacks component.
        init = function()
            ---@type boolean
            vim.g.snacks_animate = false
        end,

        ---@type snacks.Config
        opts = {
            animate = { enabled = false },
            scroll = { enabled = false },
        },
    },
}
