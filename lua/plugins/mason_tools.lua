--- Auto-install C++ toolchain binaries via Mason on startup.
--- Declarative list ensures clangd, codelldb, clang-format and cmake-language-server
--- are present on fresh machines without manual :MasonInstall steps.
--- Refs:
---   https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
---   https://github.com/mason-org/mason.nvim
return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
        ensure_installed = {
            "clangd",
            "clang-format",
            "codelldb",
            "cmake-language-server",
        },
        run_on_start = true,
    },
}
