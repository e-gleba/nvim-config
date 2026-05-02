-- Git safety + top-tier porcelain.
--
-- Problem: after changing `.gitattributes` (e.g. adding `eol=lf`), Git does
-- NOT retroactively renormalize existing tracked files. You must run
-- `git add --renormalize .` manually. We expose `:GitRenormalize` so this
-- never requires dropping to a shell.
-- https://git-scm.com/docs/git-add#Documentation/git-add.txt---renormalize
--
-- Fugitive is the de-facto standard Git plugin for Vim/Neovim (19k+ stars).
-- It provides `:G` / `:Git`, blame, diff, read/write from index, and
-- integrates with diffview.nvim already in the config.
-- https://github.com/tpope/vim-fugitive

return {
    {
        "tpope/vim-fugitive",
        cmd = {
            "Git",
            "G",
            "Gdiffsplit",
            "Gblame",
            "Gread",
            "Gwrite",
            "Gremove",
            "Gmove",
            "Ggrep",
            "Gedit",
            "Gsplit",
            "Gvsplit",
            "Gtabedit",
            "Gpedit",
            "Gwq",
            "Gcommit",
            "Gmerge",
            "Gpull",
            "Gpush",
            "Gfetch",
            "Gstatus",
        },
    },

    -- Standalone user command. Requires no plugin; plenary.nvim is already
    -- a transitive dependency (telescope, mason, etc.).
    {
        "nvim-lua/plenary.nvim",
        lazy = true,
        init = function()
            vim.api.nvim_create_user_command("GitRenormalize", function()
                local result = vim.fn.system("git add --renormalize .")
                if vim.v.shell_error == 0 then
                    vim.notify(
                        "Renormalized all tracked files. Run :Git status to verify.",
                        vim.log.levels.INFO
                    )
                else
                    vim.notify(
                        "Renormalize failed: " .. vim.trim(result),
                        vim.log.levels.ERROR
                    )
                end
            end, {
                desc = "git add --renormalize . (fix line endings after .gitattributes changes)",
            })
        end,
    },
}
