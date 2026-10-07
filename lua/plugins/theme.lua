-- tokyonight :: enforced light variant.
-- Merges into LazyVim's colorscheme spec; deltas only.
--
-- Plugin: https://github.com/folke/tokyonight.nvim

---@type LazyPluginSpec[]
return {
    {
        'folke/tokyonight.nvim',
        lazy = false,
        priority = 1000,
        opts = { style = 'day' },
    },
}
