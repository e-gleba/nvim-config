-- snacks.nvim :: core UX layer of LazyVim.
-- Only deltas from upstream defaults live here. Modules already enabled by
-- snacks.nvim's own defaults (bigfile, bufdelete, dashboard, explorer,
-- indent, input, notifier, picker, quickfile, scope, statuscolumn, words,
-- gitbrowse, lazygit, rename, scratch, terminal) are NOT repeated.
--
-- Animate kill-switch: https://github.com/folke/snacks.nvim/blob/main/docs/animate.md

---@type LazyPluginSpec[]
return {
    {
        'https://github.com/folke/snacks.nvim.git',

        -- Official global animation disable. Setting this before the plugin
        -- loads prevents the animate timer from ever starting, eliminating
        -- stutter when scrolling large C++ translation units.
        init = function()
            vim.g.snacks_animate = false
        end,

        ---@type snacks.Config
        opts = {
            -- Hard-disable modules whose upstream default is `true`.
            scroll = { enabled = false },
            animate = { enabled = false },
            zen = { enabled = false },

            -- Opt-in modules whose upstream default is `false`.
            image = { enabled = true },
        },
    },
}
