local M = {}

M.bookmarks = {
    ['scira'] = 'https://scira.ai?q=%s',
    ['you'] = 'https://you.com/search?q=%s',
    ['google'] = 'https://www.google.com/search?q=%s',
    ['github-code'] = 'https://github.com/search?q=%s&type=code',
    ['stackoverflow'] = 'https://stackoverflow.com/search?q=%s',
    ['cppreference'] = 'https://en.cppreference.com/mwiki/index.php?search=%s',
    ['c++-draft'] = 'https://eel.is/c++draft/%s',
    ['open-std'] = 'https://www.google.com/search?q=site:open-std.org+%s',
    ['quick-bench'] = 'https://quick-bench.com/',
    ['c++-stories'] = 'https://www.google.com/search?q=site:cppstories.com+%s',
    ['c++-weekly'] = 'https://www.google.com/search?q=site:youtube.com+%22c%2B%2B+weekly%22+jason+turner+%s',
    ['cmake-docs'] = 'https://cmake.org/cmake/help/latest/search.html?q=%s',
    ['boost'] = 'https://www.google.com/search?q=site:boost.org+%s',
}

local function get_query()
    local mode = vim.fn.mode()
    local is_visual = mode == 'v' or mode == 'V' or mode == '\22'
    local text

    if is_visual then
        text = table.concat(
            vim.fn.getregion(
                vim.fn.getpos('v'),
                vim.fn.getpos('.'),
                { type = mode }
            ),
            ' '
        )
    else
        text = vim.fn.expand('<cword>')
    end

    return vim.trim(text)
end

local function encode(text, plus_for_space)
    plus_for_space = plus_for_space ~= false
    local encoded = vim.uri_encode(text, 'rfc3986')
    if plus_for_space then
        encoded = encoded:gsub('%%20', '+')
    end
    return encoded
end

local function open_url(url)
    local ok, err = pcall(vim.ui.open, url)
    if not ok or err then
        vim.notify(
            string.format('Failed to open browser: %s', err or 'unknown error'),
            vim.log.levels.ERROR,
            { title = 'Browse' }
        )
    end
end

function M.search(template)
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

        open_url(template:format(encode(query)))
    end
end

function M.input_search(template, prompt)
    prompt = prompt or 'Search: '
    vim.ui.input({ prompt = prompt }, function(query)
        if not query or vim.trim(query) == '' then
            return
        end
        open_url(template:format(encode(vim.trim(query))))
    end)
end

return {
    {
        'lalitmee/browse.nvim',
        dependencies = { 'nvim-telescope/telescope.nvim' },
        opts = {
            provider = 'google',
            bookmarks = M.bookmarks,
            deduplicate_bookmarks = true,
            cache_bookmarks = true,
            create_commands = true,
        },
        keys = {
            {
                '<leader>ss',
                M.search(M.bookmarks.scira),
                desc = 'Search Scira AI',
                mode = { 'n', 'x' },
            },
            {
                '<leader>sy',
                M.search(M.bookmarks.you),
                desc = 'Search You.com',
                mode = { 'n', 'x' },
            },
            {
                '<leader>sG',
                M.search(M.bookmarks.google),
                desc = 'Search Google',
                mode = { 'n', 'x' },
            },
            {
                '<leader>sH',
                M.search(M.bookmarks['github-code']),
                desc = 'Search GitHub Code',
                mode = { 'n', 'x' },
            },
            {
                '<leader>sO',
                M.search(M.bookmarks.stackoverflow),
                desc = 'Search StackOverflow',
                mode = { 'n', 'x' },
            },
            {
                '<leader>sR',
                M.search(M.bookmarks.cppreference),
                desc = 'Search cppreference',
                mode = { 'n', 'x' },
            },
            {
                '<leader>sW',
                '<cmd>Browse input<cr>',
                desc = 'Web search (pick engine)',
                mode = { 'n', 'x' },
            },
            {
                '<leader>sB',
                '<cmd>Browse bookmarks_manual<cr>',
                desc = 'Browse bookmarks',
                mode = { 'n', 'x' },
            },
        },
    },
}
