-- lua/config/web_search.lua

local M = {}

---@type table<string, {url: string, name: string}>
M.engines = {
    -- general
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

    -- code
    github = {
        url = 'https://github.com/search?q=%s&type=code',
        name = 'github code',
    },
    stackoverflow = {
        url = 'https://stackoverflow.com/search?q=%s',
        name = 'stackoverflow',
    },

    -- c++ reference
    cppreference = {
        url = 'https://en.cppreference.com/mwiki/index.php?search=%s',
        name = 'cppreference',
    },
    cppdraft = {
        url = 'https://eel.is/c++draft/%s',
        name = 'c++ draft (eel.is)',
    },
    cppstd = {
        url = 'https://www.google.com/search?q=site:open-std.org+%s',
        name = 'open-std.org',
    },

    -- c++ tools
    godbolt = {
        url = "https://godbolt.org/#g:!((g:!((g:!((h:codeEditor,i:(filename:'1',fontScale:14,fontUsePx:'0',j:1,lang:c%%2B%%2B,selection:(endColumn:1,endLineNumber:1,positionColumn:1,positionLineNumber:1,selectionStartColumn:1,selectionStartLineNumber:1,startColumn:1,startLineNumber:1),source:''),l:'5',n:'1',o:'C%%2B%%2B+source+%%231',t:'0')),k:50,l:'4',n:'0',o:'',s:0,t:'0'),(g:!((h:compiler,i:(compiler:clang_trunk,filters:(b:'0',binary:'1',binaryObject:'1',commentOnly:'0',debugCalls:'1',demangle:'0',directives:'0',execute:'0',intel:'0',libraryCode:'0',trim:'1'),flagsViewOpen:'1',fontScale:14,fontUsePx:'0',j:1,lang:c%%2B%%2B,libs:!(),options:'-std%%3Dc%%2B%%2B23+-O2',overrides:!(),selection:(endColumn:1,endLineNumber:1,positionColumn:1,positionLineNumber:1,selectionStartColumn:1,selectionStartLineNumber:1,startColumn:1,startLineNumber:1),source:1),l:'5',n:'0',o:'+x86-64+clang+(trunk)+(Editor+%%231)',t:'0')),k:50,l:'4',n:'0',o:'',s:0,t:'0')),l:'2',n:'0',o:'',t:'0')),version:4",
        name = 'compiler explorer',
    },
    quickbench = {
        url = 'https://quick-bench.com/',
        name = 'quick-bench',
    },

    -- c++ community / news
    cppstories = {
        url = 'https://www.google.com/search?q=site:cppstories.com+%s',
        name = 'c++ stories',
    },
    cppweekly = {
        url = 'https://www.google.com/search?q=site:youtube.com+%%22c%%2B%%2B+weekly%%22+jason+turner+%s',
        name = 'c++ weekly',
    },

    -- cmake
    cmake_docs = {
        url = 'https://cmake.org/cmake/help/latest/search.html?q=%s',
        name = 'cmake docs',
    },

    -- boost
    boost = {
        url = 'https://www.google.com/search?q=site:boost.org+%s',
        name = 'boost docs',
    },

    -- rust (crates)
    crates = { url = 'https://crates.io/search?q=%s', name = 'crates.io' },
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

---@param keys table<string, {[1]: string, [2]: string}>
local function bind(keys)
    for key, def in pairs(keys) do
        local engine, desc = def[1], def[2]
        vim.keymap.set('n', key, function()
            M.search(engine)
        end, { desc = desc .. ' (yank)' })
        vim.keymap.set('x', key, function()
            M.search(engine, 'v')
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

    -- tools (no query — just opens)
    ['<leader>sE'] = { 'godbolt', 'compiler explorer' },
})

vim.keymap.set('n', '<leader>sW', function()
    M.pick('n')
end, { desc = 'web search (pick)' })
vim.keymap.set('x', '<leader>sW', function()
    M.pick('v')
end, { desc = 'web search (pick)' })

return M
