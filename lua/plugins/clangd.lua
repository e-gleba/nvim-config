---@type LazyPluginSpec[]
return {
    -- Disable the original p00f/clangd_extensions.nvim bundled by LazyVim's
    -- `lang.clangd` extra so we can use the actively maintained dchinmay2 fork.
    { 'p00f/clangd_extensions.nvim', enabled = false },

    {
        -- clangd_extensions.nvim exposes clangd-specific LSP extensions that are
        -- not part of the standard LSP spec: AST viewer, type hierarchy,
        -- symbol info, memory usage, source/header switch, and completion-score
        -- boosting for nvim-cmp. The dchinmay2 fork is actively maintained and
        -- requires Neovim 0.10+.
        -- https://github.com/dchinmay2/clangd_extensions.nvim
        -- https://sr.ht/~chinmay/clangd_extensions.nvim/
        'dchinmay2/clangd_extensions.nvim',
        name = 'clangd_extensions.nvim',
        ft = { 'c', 'cpp', 'objc', 'objcpp' },
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
    --  * --suggest-missing-includes: auto-add missing #include suggestions.
    --  * --clang-tidy              : inline linting via .clang-tidy config.
    --  * --header-insertion=iwyu   : only insert headers that are actually used.
    --  * --completion-style=detailed: show signature help in completion items.
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
        'neovim/nvim-lspconfig',
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
                        clangdFileStatus = true, -- Provides information about activity on clangd’s per-file worker thread
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
