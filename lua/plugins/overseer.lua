-- overseer.nvim :: task runner for presets, builds, ctest.
-- Loads on first command; zero startup cost.
--
-- Plugin: https://github.com/stevearc/overseer.nvim

---@type LazyPluginSpec[]
return {
    {
        'stevearc/overseer.nvim',
        cmd = {
            'OverseerOpen',
            'OverseerClose',
            'OverseerToggle',
            'OverseerRun',
            'OverseerRunCmd',
            'OverseerBuild',
            'OverseerQuickAction',
            'OverseerTaskAction',
            'OverseerInfo',
        },
        opts = {},
    },
}
