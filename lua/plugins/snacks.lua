-- snacks.nvim is the core UX layer of LazyVim.
-- For a C++ IDE we want maximum responsiveness in large files, so all
-- animations are disabled via the official upstream kill-switch.
-- Ref: https://github.com/folke/snacks.nvim/blob/main/docs/animate.md
-- Ref: https://github.com/folke/snacks.nvim/blob/main/docs/scroll.md
-- Ref: https://github.com/folke/snacks.nvim/blob/main/docs/bigfile.md

return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,

        -- Official global animation disable.  Setting this before the plugin
        -- loads prevents the animate timer from ever starting, which eliminates
        -- stutter / tabbed-window crashes when scrolling through large C++
        -- translation units or generated CMake files.
        init = function()
            vim.g.snacks_animate = false
        end,

        ---@type snacks.Config
        opts = {
            -- Explicitly disabled -------------------------------------------------
            -- Smooth scrolling is the #1 source of UI jank in big files.
            scroll = { enabled = false },

            -- Not relevant for C++ / terminal workflow.
            image = { enabled = false },
            zen = { enabled = false },

            -- Explicitly enabled IDE features -------------------------------------
            -- Bigfile guards against LSP / treesitter attaching to multi-MB
            -- generated files (unity builds, precompiled headers, etc.).
            bigfile = { enabled = true },

            -- Buffer deletion without breaking window layout.
            bufdelete = { enabled = true },

            -- File tree, fuzzy finder, and better vim.ui.input are loaded
            -- by LazyVim automatically when their extras are enabled.
            -- We keep the upstream defaults here.
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

            -- Utilities
            gitbrowse = { enabled = true },
            lazygit = { enabled = true },
            rename = { enabled = true },
            scratch = { enabled = true },
            terminal = { enabled = true },
        },
    },
}
