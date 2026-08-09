local bookmarks = {
    scira = 'https://scira.ai?q=%s',
    you = 'https://you.com/search?q=%s',
    google = 'https://www.google.com/search?q=%s',
    ['github-code'] = 'https://github.com/search?q=%s&type=code',
    stackoverflow = 'https://stackoverflow.com/search?q=%s',
    cppreference = 'https://en.cppreference.com/mwiki/index.php?search=%s',
    ['c++-draft'] = 'https://eel.is/c++draft/%s',
    ['open-std'] = 'https://www.google.com/search?q=site:open-std.org+%s',
    ['quick-bench'] = 'https://quick-bench.com/',
    ['c++-stories'] = 'https://www.google.com/search?q=site:cppstories.com+%s',
    ['c++-weekly'] = 'https://www.google.com/search?q=site:youtube.com+%22c%2B%2B+weekly%22+jason+turner+%s',
    ['cmake-docs'] = 'https://cmake.org/cmake/help/latest/search.html?q=%s',
    boost = 'https://www.google.com/search?q=site:boost.org+%s',
}

--- Word under cursor (normal mode) or selection (visual mode).
---@return string
local function get_query()
    local mode = vim.api.nvim_get_mode().mode
    if not mode:match('^[vV\22]') then
        return vim.fn.expand('<cword>')
    end
    return vim.trim(
        table.concat(
            vim.fn.getregion(
                vim.fn.getpos('v'),
                vim.fn.getpos('.'),
                { type = mode }
            ),
            ' '
        )
    )
end

--- RFC 3986-encode, using `+` for spaces (query-string convention).
---@return string
local function encode(text)
    return (vim.uri_encode(text, 'rfc3986'):gsub('%%20', '+'))
end

local function open(url)
    local ok, proc, err = pcall(vim.ui.open, url)
    if ok and proc then
        return
    end
    vim.notify(
        ('Failed to open browser: %s'):format(err or proc or 'unknown'),
        vim.log.levels.ERROR,
        { title = 'Browse' }
    )
end

--- Build a handler opening `template` (a URL containing one `%s`).
---@return function
local function search(template)
    return function()
        local query = get_query()
        if query == '' then
            vim.notify(
                'Web search: nothing selected',
                vim.log.levels.WARN,
                { title = 'Browse' }
            )
            return
        end
        open(template:format(encode(query)))
    end
end

local mode_nx = { 'n', 'x' }

-- lhs -> { bookmark, description }
local engines = {
    { '<leader>ss', 'scira', 'Search Scira AI' },
    { '<leader>sy', 'you', 'Search You.com' },
    { '<leader>sG', 'google', 'Search Google' },
    { '<leader>sH', 'github-code', 'Search GitHub Code' },
    { '<leader>sO', 'stackoverflow', 'Search StackOverflow' },
    { '<leader>sR', 'cppreference', 'Search cppreference' },
}

local keys = vim.iter(engines):map(function(e)
    return { e[1], search(bookmarks[e[2]]), desc = e[3], mode = mode_nx }
end):totable()

vim.list_extend(keys, {
    {
        '<leader>sW',
        '<cmd>Browse input<cr>',
        desc = 'Web search (pick engine)',
        mode = mode_nx,
    },
    {
        '<leader>sB',
        '<cmd>Browse bookmarks_manual<cr>',
        desc = 'Browse bookmarks',
        mode = mode_nx,
    },
})

return {
    {
        'lalitmee/browse.nvim',
        dependencies = { 'nvim-telescope/telescope.nvim' },
        opts = {
            provider = 'google',
            bookmarks = bookmarks,
            deduplicate_bookmarks = true,
            cache_bookmarks = true,
            create_commands = true,
        },
        keys = keys,
    },
}
