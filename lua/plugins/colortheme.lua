-- Colorscheme — Catppuccin (Latte)
--
-- Plugin : https://github.com/catppuccin/nvim
-- Docs   : https://github.com/catppuccin/nvim/blob/main/README.md
-- Palette: https://catppuccin.com/palette
-- LazyVim: https://lazyvim.github.io/plugins/colorscheme
--
-- Catppuccin is a community-driven pastel theme with four flavours:
--   • latte     — light, warm, high-contrast (selected below)
--   • frappe    — mid-dark, muted blue-grey base
--   • macchiato — dark, slightly warmer than mocha
--   • mocha     — darkest, deep mantle with vibrant accents
--
-- Flavour previews: https://github.com/catppuccin/nvim#-previews

---@type LazyPluginSpec[]
return {
    -- Catppuccin theme plugin
    -- https://github.com/catppuccin/nvim
    {
        'catppuccin/nvim',

        -- `name` overrides the directory lazy.nvim clones into.
        -- Without this, the plugin lands in "nvim/" which collides with
        -- the Neovim runtime. Catppuccin docs explicitly require this.
        -- https://github.com/catppuccin/nvim#lazy.nvim
        name = 'catppuccin',

        -- Colorschemes must be available at startup but should not execute
        -- their `setup()` eagerly. `lazy = true` + `priority = 1000` tells
        -- lazy.nvim: "don't load on startup, but when LazyVim requests this
        -- colorscheme, load it before everything else."
        -- https://lazy.folke.io/spec#spec-lazy-loading
        lazy = true,

        -- Priority controls load order among non-lazy plugins. 1000 is the
        -- convention for colorschemes — ensures highlight groups exist before
        -- any UI plugin (lualine, bufferline, etc.) tries to read them.
        -- Default is 50; anything above that loads earlier.
        -- https://lazy.folke.io/spec#spec-setup
        priority = 1000,

        ---@type CatppuccinOptions
        opts = {
            -- The base flavour applied when you run `:colorscheme catppuccin`
            -- (without a -suffix). When using `catppuccin-latte` as the
            -- LazyVim colorscheme (see below), this serves as a fallback.
            -- https://github.com/catppuccin/nvim#configuration
            flavour = 'latte',

            -- Maps Neovim's `background` option to flavours. This lets you
            -- toggle between light/dark with `:set bg=dark` / `:set bg=light`
            -- without changing the colorscheme string.
            -- https://github.com/catppuccin/nvim#configuration
            background = {
                light = 'latte',
                dark = 'mocha',
            },

            -- When `true`, sets the background of Normal, NormalNC, and other
            -- base groups to NONE, letting the terminal's own background show
            -- through. Useful for translucent terminals (kitty, wezterm, alacritty).
            -- Disable if you want the theme's own background colour rendered.
            -- https://github.com/catppuccin/nvim#configuration
            transparent_background = false,

            -- When `true`, sets `vim.g.terminal_color_0` … `vim.g.terminal_color_15`
            -- to Catppuccin palette values so `:terminal` buffers match your theme.
            -- https://github.com/catppuccin/nvim#configuration
            term_colors = true,

            -- Dims inactive splits by applying a darker shade to their background.
            -- `shade` — "dark" or "light" direction of the dimming.
            -- `percentage` — 0.0 (no dim) to 1.0 (fully shaded). 0.15 is subtle.
            -- https://github.com/catppuccin/nvim#dim-inactive
            dim_inactive = {
                enabled = false,
                shade = 'dark',
                percentage = 0.15,
            },

            -- Per-syntax-group font styles. Each value is a list of vim highlight
            -- attributes: "italic", "bold", "underline", "undercurl", "strikethrough".
            -- An empty table `{}` means no special styling (inherits default weight).
            --
            -- These map directly to Tree-sitter capture groups and LSP semantic
            -- tokens, so they affect every language uniformly.
            -- https://github.com/catppuccin/nvim#highlight-styles
            styles = {
                -- `@comment` capture — italicised to visually separate from code
                comments = { 'italic' },

                -- `@keyword.conditional` (if/else/match/switch)
                conditionals = { 'italic' },

                -- `@keyword.repeat` (for/while/loop)
                loops = {},

                -- `@function` and `@function.call`
                functions = {},

                -- `@keyword` (return, local, function, etc.)
                keywords = { 'bold' },

                -- `@string` literals
                strings = {},

                -- `@variable` identifiers
                variables = {},

                -- `@number` and `@number.float`
                numbers = {},

                -- `@boolean` (true/false)
                booleans = { 'bold' },

                -- `@property` (table keys, struct fields)
                properties = {},

                -- `@type` and `@type.definition`
                types = { 'bold' },

                -- `@operator` (+, -, =, etc.)
                operators = {},
            },

            -- Plugin-specific highlight integrations. Each key corresponds to a
            -- Neovim plugin; setting it to `true` (or a config table) tells
            -- Catppuccin to generate themed highlight groups for that plugin.
            --
            -- Only enable integrations for plugins you actually use — each one
            -- adds highlight groups to the load path.
            --
            -- Full list: https://github.com/catppuccin/nvim#integrations
            integrations = {
                -- https://github.com/Saghen/blink.cmp
                -- Completion menu and documentation popup highlights
                blink_cmp = true,

                -- https://github.com/nvimdev/dashboard-nvim
                -- Start screen / dashboard colours
                dashboard = true,

                -- https://github.com/folke/flash.nvim
                -- Jump labels and search highlights
                flash = true,

                -- https://github.com/lewis6991/gitsigns.nvim
                -- Git gutter signs (added/changed/deleted) and blame line
                gitsigns = true,

                -- https://github.com/lukas-reineke/indent-blankline.nvim
                -- Indent guide lines and scope highlighting.
                -- `scope_color` picks a palette colour for the active scope line.
                -- Options: any Catppuccin palette name (lavender, mauve, peach, etc.)
                -- Palette reference: https://catppuccin.com/palette
                indent_blankline = {
                    enabled = true,
                    scope_color = 'lavender',
                },

                -- https://github.com/folke/trouble.nvim
                -- Diagnostics list, quickfix, and location list panel
                lsp_trouble = true,

                -- https://github.com/mason-org/mason.nvim
                -- Mason installer UI highlights
                mason = true,

                -- https://github.com/echasnovski/mini.nvim
                -- Highlights for mini.statusline, mini.tabline, mini.indentscope, etc.
                mini = { enabled = true },

                -- Built-in Neovim LSP diagnostic highlights.
                -- `underlines` controls the decoration style per severity level.
                -- "undercurl" renders a wavy underline in supported terminals
                -- (kitty, wezterm, iTerm2); falls back to plain underline elsewhere.
                -- https://github.com/catppuccin/nvim#integrations
                native_lsp = {
                    enabled = true,
                    underlines = {
                        errors = { 'undercurl' },
                        hints = { 'undercurl' },
                        warnings = { 'undercurl' },
                        information = { 'undercurl' },
                    },
                },

                -- https://github.com/nvim-neo-tree/neo-tree.nvim
                -- File explorer tree highlights (icons, git status, diagnostics)
                neotree = true,

                -- https://github.com/folke/noice.nvim
                -- Command line popup, notification, and message area theming
                noice = true,

                -- https://github.com/rcarriga/nvim-notify
                -- Notification popup background and border colours
                notify = true,

                -- https://github.com/folke/snacks.nvim
                -- Snacks utility highlights (dashboard, picker, etc.)
                snacks = true,

                -- LSP semantic tokens use theme-aware colours instead of the
                -- default Neovim semantic highlight groups. This ensures that
                -- semantic highlights blend with Tree-sitter highlights rather
                -- than overriding them with clashing colours.
                -- https://github.com/catppuccin/nvim#integrations
                semantic_tokens = true,

                -- https://github.com/nvim-telescope/telescope.nvim
                -- Picker, prompt, results, and preview window highlights
                telescope = { enabled = true },

                -- https://github.com/nvim-treesitter/nvim-treesitter
                -- Base Tree-sitter capture group colours (@function, @keyword, etc.)
                treesitter = true,

                -- https://github.com/folke/which-key.nvim
                -- Keymap popup panel and group label colours
                which_key = true,
            },
        },
    },

    -- LazyVim core — set the active colorscheme
    -- https://lazyvim.github.io/configuration/general
    --
    -- LazyVim reads `opts.colorscheme` during startup and calls
    -- `:colorscheme <value>` before loading any other plugin.
    -- The `catppuccin-latte` string triggers Catppuccin's latte flavour
    -- directly, bypassing the `flavour` option in the plugin opts above.
    --
    -- Available strings:
    --   "catppuccin"           → uses `flavour` from plugin opts
    --   "catppuccin-latte"     → light
    --   "catppuccin-frappe"    → mid-dark
    --   "catppuccin-macchiato" → dark
    --   "catppuccin-mocha"     → darkest
    {
        'LazyVim/LazyVim',
        ---@type LazyVimOptions
        opts = {
            colorscheme = 'catppuccin-latte',
        },
    },
}
