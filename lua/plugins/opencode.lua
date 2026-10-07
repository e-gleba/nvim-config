-- opencode.nvim :: OpenCode pairing inside Neovim.
-- Keeps you in your flow: inject cursor/selection/buffer context, prompt
-- OpenCode, review its edits — no separate TUI round-trip.
--
-- Plugin: https://github.com/nickjvandyke/opencode.nvim
-- Health: `:checkhealth opencode`

---@type LazyPluginSpec[]
return {
    {
        'nickjvandyke/opencode.nvim',
        dependencies = { 'folke/snacks.nvim' },
        keys = {
            {
                '<leader>oa',
                function()
                    require('opencode').ask('@this: ')
                end,
                mode = { 'n', 'x' },
                desc = 'Opencode: ask',
            },
            {
                '<leader>os',
                function()
                    require('opencode').select()
                end,
                mode = { 'n', 'x' },
                desc = 'Opencode: select',
            },
            {
                '<leader>op',
                function()
                    require('opencode').prompt('@this')
                end,
                mode = { 'n', 'x' },
                desc = 'Opencode: prompt',
            },
            {
                '<leader>oo',
                function()
                    require('snacks.terminal').toggle(
                        'opencode',
                        { win = { position = 'right', enter = false } }
                    )
                end,
                mode = { 'n', 't' },
                desc = 'Opencode: toggle terminal',
            },
            {
                'go',
                function()
                    return require('opencode').operator('@this')
                end,
                mode = { 'n', 'x' },
                expr = true,
                desc = 'Opencode: send range',
            },
            {
                'goo',
                function()
                    return require('opencode').operator('@this') .. '_'
                end,
                mode = { 'n' },
                expr = true,
                desc = 'Opencode: send line',
            },
        },
        config = function()
            ---@type opencode.Opts
            vim.g.opencode_opts = {
                server = {
                    start = function()
                        require('snacks.terminal').open('opencode', {
                            win = { position = 'right', enter = false },
                        })
                    end,
                },
            }

            vim.api.nvim_create_autocmd('User', {
                pattern = 'OpencodeEvent:session.execution.started',
                callback = function()
                    local win = require('snacks.terminal').get(
                        'opencode',
                        { create = false }
                    )
                    if win then
                        win:show()
                    end
                end,
                desc = 'Opencode: reveal terminal on execution',
            })
        end,
    },
    {
        'folke/which-key.nvim',
        opts = {
            spec = {
                { '<leader>o', group = 'Opencode' },
            },
        },
    },
}
