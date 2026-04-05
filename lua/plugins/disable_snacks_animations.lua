-- Snacks.nvim — disable animations while preserving all functionality
-- https://github.com/folke/snacks.nvim/blob/main/docs/animate.md
-- https://lazyvim.github.io/news (search "snacks_animate")
--
-- Setting `vim.g.snacks_animate = false` is the global kill switch
-- that disables scroll, indent, dim, and all other animations [[4]] [[9]] [[10]].
-- We set it here via a plugin `init` function so it runs before
-- snacks.nvim loads — guaranteeing no animation frame ever renders.
--
-- All snacks components (explorer, picker, notifier, dashboard, etc.)
-- remain fully functional. Only the visual motion is removed.

---@type LazyPluginSpec[]
return {
    {
        'folke/snacks.nvim',

        -- `init` runs BEFORE the plugin loads — the global variable is
        -- already set by the time snacks reads it during setup.
        -- https://lazy.folke.io/spec#spec-setup
        init = function()
            vim.g.snacks_animate = false
        end,

        ---@type snacks.Config
        opts = {
            -- Smooth scrolling — disabled because it adds input latency
            -- and interferes with macro playback / dot-repeat.
            -- Falls back to native Neovim instant scroll.
            -- https://github.com/folke/snacks.nvim/blob/main/docs/scroll.md
            scroll = { enabled = false },

            -- The global `snacks_animate = false` already kills animations
            -- for every component, but we explicitly configure the animate
            -- module to make the intent clear and survive any future
            -- defaults change.
            -- https://github.com/folke/snacks.nvim/blob/main/docs/animate.md
            animate = {
                enabled = false,
            },
        },
    },
}
