---@type LazyPluginSpec[]
return {
    {
        -- conform.nvim is a lightweight, asynchronous formatter plugin.
        -- It runs external formatters (e.g. clang-format, cmake_format) in the
        -- background without blocking the editor, replacing null-ls for formatting.
        -- https://github.com/stevearc/conform.nvim
        "stevearc/conform.nvim",
        ---@type conform.setupOpts
        opts = {
            formatters_by_ft = {
                -- cmake_format formats CMakeLists.txt and *.cmake files.
                -- It reads .cmake-format.py from the repo root when present.
                -- https://github.com/cheshirekow/cmake_format
                cmake = { "cmake_format" },

                -- clang-format is the LLVM/Clang project's official C/C++ formatter.
                -- It uses a .clang-format file in your repo root for style rules.
                -- https://clang.llvm.org/docs/ClangFormat.html
                c = { "clang_format" },
                cpp = { "clang_format" },
            },
        },
    },
}
