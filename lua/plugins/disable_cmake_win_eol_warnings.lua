-- Pylint C0327: mixed-line-endings (LF + CRLF in one file)
-- Docs: https://pylint.pycqa.org/en/latest/user_guide/messages/convention/mixed-line-endings.html
-- Overview: https://pylint.readthedocs.io/en/stable/user_guide/messages/messages_overview.html
-- LazyVim LSP: https://www.lazyvim.org/plugins/lsp
return {
    'neovim/nvim-lspconfig',
    init = function()
        local orig = vim.lsp.handlers['textDocument/publishDiagnostics']
        vim.lsp.handlers['textDocument/publishDiagnostics'] = function(
            err,
            result,
            ctx,
            config
        )
            if result and result.diagnostics then
                result.diagnostics = vim.tbl_filter(function(d)
                    return not d.message:find('[C0327]', 1, true)
                end, result.diagnostics)
            end
            orig(err, result, ctx, config)
        end
    end,
}
