-- Flavour previews: https://github.com/catppuccin/nvim#-previews

---@type LazyPluginSpec[]
return {
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
