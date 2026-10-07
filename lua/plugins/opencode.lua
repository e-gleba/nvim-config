return {
    'nickjvandyke/opencode.nvim',
    -- Defaults to "main", supporting OpenCode v2.
    -- Uncomment to pull the latest stable release, supporting OpenCode v1.
    -- version = "*",
    config = function()
        ---@type opencode.Opts
        vim.g.opencode_opts = {
            -- Your configuration, if any; goto definition on the type for details
        }

        -- Recommended/example keymaps
        vim.keymap.set({ 'n', 'x' }, '<C-a>', function()
            require('opencode').ask('@this: ')
        end, { desc = 'Ask OpenCode…' })
        vim.keymap.set({ 'n', 'x' }, '<C-x>', function()
            require('opencode').select()
        end, { desc = 'Select OpenCode…' })
        vim.keymap.set({ 'n', 'x' }, 'go', function()
            return require('opencode').operator('@this')
        end, { desc = 'Send range to OpenCode', expr = true })
        vim.keymap.set({ 'n' }, 'goo', function()
            return require('opencode').operator('@this') .. '_'
        end, { desc = 'Send line to OpenCode', expr = true })
    end,
}
