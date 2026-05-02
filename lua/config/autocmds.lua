-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Jira commit prefix: extract issue key (e.g. PROJ-123) from the current
-- git branch and prepend it to the commit message buffer. Zero auth, zero
-- API calls — works offline and on any repo that uses Jira-style branch names.
-- Supports patterns like: feature/PROJ-123-description, PROJ-123-fix-bug, etc.
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'gitcommit',
    callback = function()
        local branch = vim.fn.trim(vim.fn.system({ 'git', 'branch', '--show-current' }))
        if vim.v.shell_error ~= 0 then
            return
        end

        local key = branch:match('([A-Z][A-Z0-9]*%-%d+)')
        if not key then
            return
        end

        local buf = vim.api.nvim_get_current_buf()
        local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ''

        -- Only inject if the first line is empty (not an amend or reword).
        if line:match('^%s*$') then
            local prefix = key .. ': '
            vim.api.nvim_buf_set_lines(buf, 0, 1, false, { prefix })
            vim.api.nvim_win_set_cursor(0, { 1, #prefix })
        end
    end,
})

-- Clangd cache wipe and LSP restart.
--
-- clangd maintains a background index on disk (under .cache/clangd and the
-- global ~/.cache/clangd). On large codebases this cache can drift after
-- rebases, branch switches, or unity-build toggles, producing phantom
-- errors, missing symbols, or stale cross-file references. This command
-- deletes both caches and restarts the LSP — fixes 90 % of "worked
-- yesterday, broken today" clangd issues in ~2 seconds.
--
-- Usage:
--   :ClangdWipeCache
--
-- Ref: https://clangd.llvm.org/design/indexing.html
vim.api.nvim_create_user_command('ClangdWipeCache', function()
    local dirs = {
        vim.loop.cwd() .. '/.cache/clangd',
        vim.fn.expand('~/.cache/clangd'),
    }
    for _, d in ipairs(dirs) do
        if vim.fn.isdirectory(d) == 1 then
            vim.fn.delete(d, 'rf')
        end
    end
    vim.cmd('LspRestart')
    vim.notify('clangd cache wiped & LSP restarted', vim.log.levels.INFO)
end, { desc = 'Wipe clangd index cache and restart LSP' })
