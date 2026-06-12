---@type LazyPluginSpec[]
return {
    -- Disable the unmaintained p00f fork bundled by LazyVim's `lang.clangd` extra.
    -- https://github.com/p00f/clangd_extensions.nvim
    { 'https://github.com/p00f/clangd_extensions.nvim.git', enabled = false },

    -- clangd_extensions.nvim exposes clangd-specific LSP extensions that are not
    -- part of the standard LSP spec: AST viewer, type hierarchy, symbol info,
    -- memory usage, source/header switch, and completion-score boosting for
    -- nvim-cmp. The dchinmay2 fork is actively maintained and requires Neovim 0.10+.
    -- https://github.com/dchinmay2/clangd_extensions.nvim
    -- https://sr.ht/~chinmay/clangd_extensions.nvim/
    {
        'https://github.com/dchinmay2/clangd_extensions.nvim.git',
        name = 'clangd_extensions.nvim',
        ft = { 'c', 'cpp', 'objc', 'objcpp' },
        opts = {
            ast = {
                role_icons = {
                    type = '',
                    declaration = '',
                    expression = '',
                    specifier = '',
                    statement = '',
                    ['template argument'] = '',
                },
                kind_icons = {
                    compound = '',
                    recovery = '',
                    translation_unit = '',
                    pack_expansion = '',
                    template_type_parm = '',
                    template_non_type_parm = '',
                    template_template_parm = '',
                    template_param_object = '',
                },
                highlights = {
                    detail = 'Comment',
                },
            },
            memory_usage = {
                border = 'rounded',
            },
            symbol_info = {
                border = 'rounded',
            },
        },
    },

    -- Hardened clangd server flags.
    --
    -- The defaults bundled by LazyVim (and most copy-pasted configs) include
    -- obsolete / crash-prone flags that cause instability on large C++ codebases
    -- (especially on Windows with unity builds or non-unity builds). This override
    -- replaces them with a minimal, conservative set that maximises stability.
    --
    -- Rationale for each flag:
    --
    --  * --background-index        : incremental index, required for workspace symbols.
    --  * --background-index-priority=low : keep clangd polite while indexing.
    --  * --clang-tidy              : inline linting via .clang-tidy config.
    --  * --header-insertion=iwyu   : only insert headers that are actually used.
    --  * --header-insertion-decorators : mark auto-inserted headers with // IWYU pragma.
    --  * --all-scopes-completion   : complete symbols from all scopes, not just current.
    --  * --completion-style=detailed : show signature help in completion items.
    --  * --function-arg-placeholders : insert <#arg#> placeholders on completion.
    --  * --fallback-style=llvm     : default formatting style when no .clang-format exists.
    --  * --log=error               : suppress noisy info spam in :LspLog.
    --  * --j=4                     : cap background-index threads to avoid starving
    --                                 the OS scheduler on 8+ core machines.
    --
    -- Removed (do NOT add back):
    --  * --cross-file-rename       : obsolete since clangd 18+, causes init errors.
    --  * --experimental-modules-support : known crash trigger.
    --                                 https://github.com/clangd/clangd/issues/2392
    --  * --pch-storage=memory      : see above.
    --
    -- Windows-specific: add --query-driver pointing to your real compiler
    -- (MinGW g++.exe, MSVC cl.exe, etc.) so clangd can discover system includes.
    -- https://github.com/clangd/clangd/discussions/2489
    --
    -- Example MinGW64:
    --   "--query-driver=C:/msys64/mingw64/bin/g++.exe,C:/msys64/mingw64/bin/clang++.exe"
    -- Example MSVC:
    --   "--query-driver=C:/Program Files/.../Hostx64/x64/cl.exe"
    {
        'https://github.com/neovim/nvim-lspconfig.git',
        opts = {
            servers = {
                clangd = {
                    cmd = {
                        'clangd',
                        '--background-index',
                        '--background-index-priority=low',
                        '--clang-tidy',
                        '--header-insertion=iwyu',
                        '--header-insertion-decorators',
                        '--all-scopes-completion',
                        '--completion-style=detailed',
                        '--function-arg-placeholders',
                        '--fallback-style=llvm',
                        '--log=error',
                        '-j=4',
                    },
                    init_options = {
                        clangdFileStatus = true,
                        usePlaceholders = true,
                        completeUnimported = true,
                        semanticHighlighting = true,
                        fallbackFlags = { '-std=c++23' },
                    },
                },
            },
        },
    },
}
