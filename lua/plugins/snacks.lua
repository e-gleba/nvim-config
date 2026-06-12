-- snacks.nvim :: core UX layer of LazyVim.
-- For a C++ IDE we want maximum responsiveness in large files, so animations
-- are disabled via the official upstream kill-switch.
--
-- Animate: https://github.com/folke/snacks.nvim/blob/main/docs/animate.md
-- Scroll:  https://github.com/folke/snacks.nvim/blob/main/docs/scroll.md
-- Bigfile: https://github.com/folke/snacks.nvim/blob/main/docs/bigfile.md
-- Docs:    https://github.com/folke/snacks.nvim/blob/main/docs

---@type LazyPluginSpec[]
return {
    {
        'https://github.com/folke/snacks.nvim.git',
        priority = 1000,
        lazy = false,

        -- Official global animation disable. Setting this before the plugin loads
        -- prevents the animate timer from ever starting, which eliminates stutter
        -- and tabbed-window crashes when scrolling through large C++ translation
        -- units or generated CMake files.
        init = function()
            vim.g.snacks_animate = false
        end,

        ---@type snacks.Config
        opts = {
            -- Performance: disabled -------------------------------------------------
            scroll = { enabled = false },
            animate = { enabled = false },
            zen = { enabled = false },

            -- Performance: enabled --------------------------------------------------
            bigfile = {
                enabled = true,
                size = 1.5 * 1024 * 1024, -- 1.5 MB
                line_length = 1000,
            },

            -- Core IDE features -----------------------------------------------------
            bufdelete = { enabled = true },
            dashboard = { enabled = true },
            explorer = { enabled = true },
            indent = { enabled = true },
            input = { enabled = true },
            notifier = { enabled = true },
            picker = { enabled = true },
            quickfile = { enabled = true },
            scope = { enabled = true },
            statuscolumn = { enabled = true },
            words = { enabled = true },

            -- Utilities -------------------------------------------------------------
            gitbrowse = { enabled = true },
            lazygit = { enabled = true },
            rename = { enabled = true },
            scratch = { enabled = true },
            terminal = { enabled = true },
            image = { enabled = true },
        },
    },
}
