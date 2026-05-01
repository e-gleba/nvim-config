---@type LazyPluginSpec[]
return {
    {
        -- clangd_extensions.nvim adds extra IDE features on top of the clangd LSP:
        -- type hierarchy, symbol info, inlay hints, AST view, memory usage, etc.
        -- It is loaded automatically by LazyVim's `lang.clangd` extra; this spec
        -- only customizes the default options.
        -- https://github.com/p00f/clangd_extensions.nvim
        "p00f/clangd_extensions.nvim",
        opts = {
            inlay_hints = {
                inline = vim.fn.has("nvim-0.10") == 1,
                only_current_line = false,
            },
            ast = {
                role_icons = {
                    type = "",
                    declaration = "",
                    expression = "",
                    specifier = "",
                    statement = "",
                    ["template argument"] = "",
                },
                kind_icons = {
                    Compound = "",
                    Recovery = "",
                    TranslationUnit = "",
                    PackExpansion = "",
                    TemplateTypeParm = "",
                    TemplateTemplateParm = "",
                    TemplateParamObject = "",
                },
            },
        },
    },
}
