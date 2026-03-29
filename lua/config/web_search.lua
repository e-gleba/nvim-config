-- lua/config/web_search.lua

local M = {}

---@type table<string, {url: string, name: string}>
M.engines = {
    google = {
        url = 'https://www.google.com/search?q=%s',
        name = 'google',
    },
    perplexity = {
        url = 'https://www.perplexity.ai/search?q=%s',
        name = 'perplexity',
    },
    you = {
        url = 'https://you.com/search?q=%s&fromSearchBar=true',
        name = 'you.com',
    },
    github = {
        url = 'https://github.com/search?q=%s&type=code',
        name = 'github',
    },
    stackoverflow = {
        url = 'https://stackoverflow.com/search?q=%s',
        name = 'stackoverflow',
    },
    cppreference = {
        url = 'https://en.cppreference.com/mwiki/index.php?search=%s',
        name = 'cppreference',
    },
    duckduckgo = {
        url = 'https://duckduckgo.com/?q=%s',
        name = 'duckduckgo',
    },
}

---@param s string
---@return string
local function url_encode(s)
    local encoded = s:gsub('\n', ' ')
        :gsub('([^%w %-%_%.%~])', function(c)
            return ('%%%02X'):format(c:byte())
        end)
        :gsub(' ', '+')
    return encoded
end

---@return string
local function get_visual_selection()
    local old = vim.fn.getreg('v')
    local old_type = vim.fn.getregtype('v')
    vim.cmd('noautocmd normal! "vy')
    local text = vim.fn.getreg('v')
    vim.fn.setreg('v', old, old_type)
    return text
end

---@param engine_key string
---@param mode? "v"|"n"
function M.search(engine_key, mode)
    local engine = M.engines[engine_key]
    if not engine then
        return vim.notify(
            'unknown engine: ' .. engine_key,
            vim.log.levels.ERROR
        )
    end

    local text = mode == 'v' and get_visual_selection() or vim.fn.getreg('"')
    text = vim.trim(text)

    if text == '' then
        return vim.notify('nothing to search', vim.log.levels.WARN)
    end

    local url = engine.url:format(url_encode(text))
    vim.ui.open(url)
    vim.notify(engine.name .. ': ' .. text:sub(1, 50), vim.log.levels.INFO)
end

---@param mode? "v"|"n"
function M.pick(mode)
    local names = vim.tbl_keys(M.engines)
    table.sort(names)
    vim.ui.select(names, {
        prompt = 'search with:',
        format_item = function(key)
            return M.engines[key].name
        end,
    }, function(choice)
        if choice then
            M.search(choice, mode)
        end
    end)
end

local map = vim.keymap.set

map('n', '<leader>sG', function()
    M.search('google')
end, { desc = 'search google (yank)' })
map('n', '<leader>sP', function()
    M.search('perplexity')
end, { desc = 'search perplexity (yank)' })
map('n', '<leader>sY', function()
    M.search('you')
end, { desc = 'search you.com (yank)' })
map('n', '<leader>sR', function()
    M.search('cppreference')
end, { desc = 'search cppreference (yank)' })
map('n', '<leader>sO', function()
    M.search('stackoverflow')
end, { desc = 'search stackoverflow (yank)' })
map('n', '<leader>sH', function()
    M.search('github')
end, { desc = 'search github (yank)' })
map('n', '<leader>sW', function()
    M.pick('n')
end, { desc = 'web search (pick engine)' })

map('x', '<leader>sG', function()
    M.search('google', 'v')
end, { desc = 'search google' })
map('x', '<leader>sP', function()
    M.search('perplexity', 'v')
end, { desc = 'search perplexity' })
map('x', '<leader>sY', function()
    M.search('you', 'v')
end, { desc = 'search you.com' })
map('x', '<leader>sR', function()
    M.search('cppreference', 'v')
end, { desc = 'search cppreference' })
map('x', '<leader>sO', function()
    M.search('stackoverflow', 'v')
end, { desc = 'search stackoverflow' })
map('x', '<leader>sH', function()
    M.search('github', 'v')
end, { desc = 'search github' })
map('x', '<leader>sW', function()
    M.pick('v')
end, { desc = 'web search (pick engine)' })

return M
