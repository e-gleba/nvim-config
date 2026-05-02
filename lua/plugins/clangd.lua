---@type LazyPluginSpec[]
return {
    -- Disable the original p00f/clangd_extensions.nvim bundled by LazyVim's
    -- `lang.clangd` extra so we can use the actively maintained dchinmay2 fork.
    { "p00f/clangd_extensions.nvim", enabled = false },

    {
        -- clangd_extensions.nvim exposes clangd-specific LSP extensions that are
        -- not part of the standard LSP spec: AST viewer, type hierarchy,
        -- symbol info, memory usage, source/header switch, and completion-score
        -- boosting for nvim-cmp. The dchinmay2 fork is actively maintained and
        -- requires Neovim 0.10+.
        -- https://github.com/dchinmay2/clangd_extensions.nvim
        -- https://sr.ht/~chinmay/clangd_extensions.nvim/
        "dchinmay2/clangd_extensions.nvim",
        name = "clangd_extensions.nvim",
        ft = { "c", "cpp", "objc", "objcpp" },
        ---@type ClangdExt.Opts
        opts = {
            ast = {
                -- Icons below use Unicode Geometric Shapes / Misc Symbols so
                -- they render correctly in any standard monospace font without
                -- requiring a Nerd Font patchset.
                role_icons = {
                    type = "◆",
                    declaration = "◇",
                    expression = "●",
                    specifier = "▸",
                    statement = "■",
                    ["template argument"] = "◊",
                },
                kind_icons = {
                    Compound = "◇",
                    Recovery = "⚠",
                    TranslationUnit = "◎",
                    PackExpansion = "⋯",
                    TemplateTypeParm = "◊",
                    TemplateTemplateParm = "◊",
                    TemplateParamObject = "◊",
                },
                highlights = {
                    detail = "Comment",
                },
            },
            memory_usage = {
                border = "rounded",
            },
            symbol_info = {
                border = "rounded",
            },
        },
    },
}
