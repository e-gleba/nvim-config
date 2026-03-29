-- lua/config/web_search.lua

local M = {}

---@alias Engine { [1]: string, [2]: string } -- { url_template, display_name }

---@type table<string, Engine>
M.engines = {
    -- general
    google = { 'https://www.google.com/search?q=%s', 'google' },
    perplexity = { 'https://www.perplexity.ai/search?q=%s', 'perplexity' },
    you = { 'https://you.com/search?q=%s&fromSearchBar=true', 'you.com' },

    -- code
    github = { 'https://github.com/search?q=%s&type=code', 'github code' },
    stackoverflow = { 'https://stackoverflow.com/search?q=%s', 'stackoverflow' },

    -- c++ reference
    cppreference = {
        'https://en.cppreference.com/mwiki/index.php?search=%s',
        'cppreference',
    },
    cppdraft = { 'https://eel.is/c++draft/%s', 'c++ draft (eel.is)' },
    cppstd = {
        'https://www.google.com/search?q=site:open-std.org+%s',
        'open-std.org',
    },

    quickbench = { 'https://quick-bench.com/', 'quick-bench' },

    -- c++ community / news
    cppstories = {
        'https://www.google.com/search?q=site:cppstories.com+%s',
        'c++ stories',
    },
    cppweekly = {
        'https://www.google.com/search?q=site:youtube.com+%%22c%%2B%%2B+weekly%%22+jason+turner+%s',
        'c++ weekly',
    },

    -- cmake
    cmake_docs = {
        'https://cmake.org/cmake/help/latest/search.html?q=%s',
        'cmake docs',
    },

    -- boost
    boost = {
        'https://www.google.com/search?q=site:boost.org+%s',
        'boost docs',
    },
}

local _sorted_engine_keys ---@type string[]?

---@return string[]
local function sorted_engine_keys()
    if not _sorted_engine_keys then
        _sorted_engine_keys = vim.tbl_keys(M.engines)
        table.sort(_sorted_engine_keys)
    end
    return _sorted_engine_keys
end

---@param s string
---@return string
local function query_encode(s)
    return vim.uri_encode(s:gsub('\n', ' ')):gsub('%%20', '+')
end

---@return string
local function get_visual_selection()
    return table.concat(
        vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.')),
        '\n'
    )
end

---@param engine_key string
---@param visual? boolean
function M.search(engine_key, visual)
    local engine = M.engines[engine_key]
    if not engine then
        return vim.notify(
            'unknown engine: ' .. engine_key,
            vim.log.levels.ERROR
        )
    end

    local text = visual and get_visual_selection() or vim.fn.getreg('"')
    text = vim.trim(text)

    if text == '' then
        return vim.notify('nothing to search', vim.log.levels.WARN)
    end

    local url = engine[1]:format(query_encode(text))
    vim.ui.open(url)
    vim.notify(
        ('%s: %s'):format(engine[2], text:sub(1, 50)),
        vim.log.levels.INFO
    )
end

---@param visual? boolean
function M.pick(visual)
    vim.ui.select(sorted_engine_keys(), {
        prompt = 'search with:',
        format_item = function(key)
            return M.engines[key][2]
        end,
    }, function(choice)
        if choice then
            M.search(choice, visual)
        end
    end)
end

---@param keys table<string, { [1]: string, [2]: string }>
local function bind(keys)
    for lhs, def in pairs(keys) do
        local engine, desc = def[1], def[2]

        vim.keymap.set('n', lhs, function()
            M.search(engine)
        end, { desc = desc .. ' (yank)' })

        vim.keymap.set('x', lhs, function()
            M.search(engine, true)
        end, { desc = desc })
    end
end

bind({
    -- general
    ['<leader>sG'] = { 'google', 'search google' },
    ['<leader>sP'] = { 'perplexity', 'search perplexity' },
    ['<leader>sY'] = { 'you', 'search you.com' },

    -- code
    ['<leader>sH'] = { 'github', 'search github' },
    ['<leader>sO'] = { 'stackoverflow', 'search stackoverflow' },

    -- c++
    ['<leader>sR'] = { 'cppreference', 'search cppreference' },
    ['<leader>sD'] = { 'cppdraft', 'search c++ draft' },
    ['<leader>sS'] = { 'cppstd', 'search open-std' },
    ['<leader>sB'] = { 'boost', 'search boost' },
    ['<leader>sC'] = { 'cmake_docs', 'search cmake docs' },
})

vim.keymap.set('n', '<leader>sW', function()
    M.pick(false)
end, { desc = 'web search (pick)' })

vim.keymap.set('x', '<leader>sW', function()
    M.pick(true)
end, { desc = 'web search (pick)' })

return M
