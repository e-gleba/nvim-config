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
