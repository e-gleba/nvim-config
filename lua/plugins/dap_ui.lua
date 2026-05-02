--- IDE-grade debugging UI for C++.
--- nvim-dap-ui renders scopes, watches, call stack and breakpoints in side panels.
--- nvim-dap-virtual-text prints variable values inline next to source lines.
--- Refs:
---   https://github.com/rcarriga/nvim-dap-ui
---   https://github.com/theHamsta/nvim-dap-virtual-text
---   https://github.com/mfussenegger/nvim-dap
return {
    {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
        opts = {},
    },
    {
        'theHamsta/nvim-dap-virtual-text',
        opts = {},
    },
}
