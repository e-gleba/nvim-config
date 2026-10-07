-- opencode.nvim :: OpenCode pairing inside Neovim.
-- Inject cursor/selection context, prompt, review edits — no TUI round-trip.
--
-- Plugin: https://github.com/nickjvandyke/opencode.nvim
-- Health: `:checkhealth opencode`

-- snacks.nvim is LazyVim core (eager), so no `dependencies` entry needed.
local term_opts = { win = { position = 'right', enter = false } }

---@type LazyPluginSpec[]
return {
    {
        'nickjvandyke/opencode.nvim',
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
                    require('snacks.terminal').toggle('opencode', term_opts)
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
                        require('snacks.terminal').open('opencode', term_opts)
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
        -- Send snacks picker selection to opencode via `<a-o>`.
        -- Ref: https://github.com/nickjvandyke/opencode.nvim#integrations
        'folke/snacks.nvim',
        opts = {
            picker = {
                win = {
                    input = {
                        keys = {
                            ['<a-o>'] = {
                                'opencode_send',
                                mode = { 'n', 'i' },
                            },
                        },
                    },
                },
                actions = {
                    ---@param picker snacks.Picker
                    opencode_send = function(picker)
                        local items = vim.tbl_map(function(item)
                            ---@param item snacks.picker.Item
                            return item.file
                                and require('opencode').format({
                                    path = item.file,
                                    from = item.pos,
                                    to = item.end_pos,
                                })
                                or item.text
                        end, picker:selected({ fallback = true }))
                        require('opencode').prompt(
                            table.concat(items, ', ') .. ' '
                        )
                    end,
                },
            },
        },
    },
    {
        'folke/which-key.nvim',
        opts = {
            spec = {
                {
                    '<leader>o',
                    group = 'Opencode',
                    icon = { icon = '󰚩 ', color = 'purple' },
                },
            },
        },
    },
}
