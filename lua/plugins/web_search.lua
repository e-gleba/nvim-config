-- Fast web search: select text in visual mode (or use word under cursor in normal
-- mode), hit a keymap, and jump straight to results in the system browser.
-- Uses browse.nvim for the bookmark registry / picker; these keymaps bypass
-- the picker for the most common engines.
-- Ref: https://github.com/lalitmee/browse.nvim

local bookmarks = {
    -- General
    google = 'https://www.google.com/search?q=%s',
    perplexity = 'https://www.perplexity.ai/search?q=%s',

    -- Code
    ['github-code'] = 'https://github.com/search?q=%s&type=code',
    stackoverflow = 'https://stackoverflow.com/search?q=%s',

    -- C++ Reference
    cppreference = 'https://en.cppreference.com/mwiki/index.php?search=%s',
    ['c++-draft'] = 'https://eel.is/c++draft/%s',
    ['open-std'] = 'https://www.google.com/search?q=site:open-std.org+%s',

    -- C++ Tooling
    ['quick-bench'] = 'https://quick-bench.com/',

    -- C++ Community
    ['c++-stories'] = 'https://www.google.com/search?q=site:cppstories.com+%s',
    ['c++-weekly'] = 'https://www.google.com/search?q=site:youtube.com+%22c%2B%2B+weekly%22+jason+turner+%s',

    -- CMake
    ['cmake-docs'] = 'https://cmake.org/cmake/help/latest/search.html?q=%s',

    -- Boost
    boost = 'https://www.google.com/search?q=site:boost.org+%s',
}

--- Return a keymap callback that searches `template` with the current word or
--- visual selection.  Delegates to vim.ui.open (xdg-open / open / start).
local function search(template)
    return function()
        local mode = vim.fn.mode()
        local text
        if mode == 'v' or mode == 'V' or mode == '\22' then
            text = table.concat(
                vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = mode }),
                ' '
            )
        else
            text = vim.fn.expand('<cword>')
        end

        text = vim.trim(text)
        if text == '' then
            vim.notify('Web search: nothing selected', vim.log.levels.WARN)
            return
        end

        local encoded = vim.uri_encode(text):gsub('%%20', '+')
        vim.ui.open(template:format(encoded))
    end
end

return {
    {
        'lalitmee/browse.nvim',
        dependencies = { 'nvim-telescope/telescope.nvim' },
        opts = {
            provider = 'google',
            bookmarks = bookmarks,
        },
        keys = {
            { '<leader>sG', search(bookmarks.google), desc = 'Search Google', mode = { 'n', 'x' } },
            { '<leader>sH', search(bookmarks['github-code']), desc = 'Search GitHub Code', mode = { 'n', 'x' } },
            { '<leader>sO', search(bookmarks.stackoverflow), desc = 'Search StackOverflow', mode = { 'n', 'x' } },
            { '<leader>sR', search(bookmarks.cppreference), desc = 'Search cppreference', mode = { 'n', 'x' } },
            { '<leader>sW', '<cmd>Browse input<cr>', desc = 'Web search (pick engine)', mode = { 'n', 'x' } },
        },
    },
}
