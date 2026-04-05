-- ============================================================================
-- C/C++ Language Support — clangd LSP + Extensions
-- ============================================================================
--
-- Plugins:
--   clangd_extensions : https://sr.ht/~chinmay/clangd_extensions.nvim
--                       (mirror: https://github.com/dchinmay2/clangd_extensions.nvim)
--   nvim-lspconfig    : https://github.com/neovim/nvim-lspconfig
--
-- Prerequisites:
--   • clangd (LLVM ≥ 17 recommended)
--   • clang-tidy (ships with LLVM)
--
-- Usage:
--   :ClangdMemoryUsage        — AST memory breakdown per TU
--   :ClangdSymbolInfo          — symbol details under cursor
--   :ClangdSwitchSourceHeader  — toggle .h ↔ .cpp
--   :ClangdAST                 — dump AST of current buffer
--   :ClangdTypeHierarchy       — show type hierarchy
--

---Border style shared across all clangd extension floating windows.
---These windows are rendered by the plugin itself and do NOT inherit
---from LazyVim's global `vim.lsp.buf` border settings, so we must
---set them explicitly here for visual consistency.
---@type string
local border = 'rounded'

---@type LazyPluginSpec[]
return {
    -- ──────────────────────────────────────────────────────────────────────
    -- clangd_extensions.nvim (sourcehut)
    -- Provides inlay hints, memory usage, symbol info, AST, type hierarchy
    -- Canonical : https://sr.ht/~chinmay/clangd_extensions.nvim
    -- Git       : https://git.sr.ht/~chinmay/clangd_extensions.nvim
    -- Mirror    : https://github.com/dchinmay2/clangd_extensions.nvim
    -- ──────────────────────────────────────────────────────────────────────
    {
        -- sourcehut repos require explicit `url`; lazy.nvim short syntax
        -- only works for GitHub "owner/repo" strings.
        url = 'https://git.sr.ht/~chinmay/clangd_extensions.nvim',
        name = 'clangd_extensions.nvim',
        lazy = true,
        ---@type ClangdExtensionsConfig
        opts = {
            inlay_hints = {
                inline = true,
            },
            ast = {
                role_icons = {
                    type = '🄣',
                    declaration = '🄓',
                    expression = '🄔',
                    statement = ';',
                    specifier = '🄢',
                    ['template argument'] = '🆃',
                },
                kind_icons = {
                    Compound = '🄲',
                    Recovery = '🅁',
                    TranslationUnit = '🅄',
                    PackExpansion = '🄿',
                    TemplateTypeParm = '🅃',
                    TemplateTemplateParm = '🅃',
                    TemplateParamObject = '🅃',
                },
            },
            memory_usage = {
                border = border,
            },
            symbol_info = {
                border = border,
            },
        },
    },

    -- ──────────────────────────────────────────────────────────────────────
    -- nvim-lspconfig — clangd server configuration
    -- https://github.com/neovim/nvim-lspconfig
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#clangd
    -- ──────────────────────────────────────────────────────────────────────
    {
        'neovim/nvim-lspconfig',
        ---@type PluginLspOpts
        opts = {
            servers = {
                clangd = {
                    -- NOTE: LazyVim merges this table into its defaults via
                    -- `vim.tbl_deep_extend`, so we only specify overrides here.
                    -- Do NOT set `root_dir` unless you have a non-standard layout;
                    -- nvim-lspconfig auto-detects compile_commands.json, .clangd,
                    -- .clang-tidy, .clang-format, and CMakeLists.txt.

                    ---@type string[]
                    cmd = {
                        'clangd',

                        -- Enable clang-tidy diagnostics alongside clangd's own
                        '--clang-tidy',

                        -- Show full overload / template parameter info in completions
                        '--completion-style=detailed',

                        -- Function argument placeholders in completions
                        '--function-arg-placeholders',

                        -- Keep preamble (PCH) in memory — faster reparse at the cost
                        -- of ~100-300 MB RAM per TU. Use "disk" on constrained systems.
                        '--pch-storage=memory',

                        -- Background indexing for go-to-definition across TUs
                        '--background-index',

                        -- Parallel indexing threads (adjust to your core count)
                        '-j=4',

                        -- Cap results to keep completion responsive in large codebases
                        '--limit-references=200',
                        '--limit-results=30',

                        -- Header insertion policy — "iwyu" (include-what-you-use) or "never"
                        '--header-insertion=iwyu',

                        -- Show origins of completions (useful for debugging)
                        '--header-insertion-decorators',

                        -- Fall back to built-in headers when compile_commands.json is missing
                        '--fallback-style=llvm',

                        -- Log level — bump to "verbose" when diagnosing clangd issues
                        '--log=error',
                    },

                    ---@type table<string, any>
                    init_options = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },

                    -- Extend default capabilities with offset encoding expected by clangd
                    ---@param new_config table
                    ---@param root_dir string
                    on_new_config = function(new_config, root_dir)
                        -- clangd requires UTF-16 offset encoding
                        new_config.capabilities = vim.tbl_deep_extend(
                            'force',
                            new_config.capabilities or {},
                            { offsetEncoding = { 'utf-16' } }
                        )
                    end,
                },
            },

            -- Attach clangd_extensions when the LSP client attaches
            ---@param client vim.lsp.Client
            ---@param bufnr integer
            setup = {
                clangd = function(_, opts)
                    local clangd_ext = require('clangd_extensions')

                    -- clangd_extensions.setup must be called BEFORE lspconfig.clangd.setup
                    -- LazyVim calls this `setup[server]` function instead of the default
                    -- lspconfig setup, so we handle everything here.
                    clangd_ext.setup({
                        server = opts,
                    })

                    -- Return true to tell LazyVim we handled the setup ourselves
                    return true
                end,
            },
        },
    },
}
