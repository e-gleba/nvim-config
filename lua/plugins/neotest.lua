--- Google Test adapter for Neotest.
--- Auto-discovers gtest executables and runs individual TEST_F cases inside Neovim.
--- Refs:
---   https://github.com/alfaix/neotest-gtest
---   https://github.com/nvim-neotest/neotest
return {
    {
        "nvim-neotest/neotest",
        dependencies = { "alfaix/neotest-gtest" },
        opts = function(_, opts)
            opts.adapters = opts.adapters or {}
            table.insert(opts.adapters, require("neotest-gtest"))
        end,
    },
}
