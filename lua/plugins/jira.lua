-- Optional Jira integration via letieu/jira.nvim.
-- Loads only if JIRA_DOMAIN env var is set so it stays invisible for users
-- without corporate Jira access.
--
-- To activate:
--   export JIRA_DOMAIN=yourcompany.atlassian.net
--   export JIRA_USER=your-email@company.com
--   export JIRA_API_TOKEN=your-api-token
-- Then run :Jira auth login inside Neovim.
--
-- Ref: https://github.com/letieu/jira.nvim
return {
    {
        'letieu/jira.nvim',
        cond = function()
            return vim.env.JIRA_DOMAIN ~= nil
        end,
        dependencies = { 'nvim-telescope/telescope.nvim' },
        opts = {},
        keys = {
            { '<leader>jj', '<cmd>Jira<cr>', desc = 'Jira board', mode = 'n' },
            {
                '<leader>ji',
                '<cmd>Jira info<cr>',
                desc = 'Jira issue info',
                mode = 'n',
            },
        },
    },
}
