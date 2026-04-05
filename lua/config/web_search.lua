-- Web Search — open search engines from Neovim
--
-- Opens a browser tab with the selected text (visual mode) or the
-- contents of the unnamed register (normal mode, last yank/delete).
--
-- Usage:
--   <leader>sW  — pick an engine from a menu, then search
--   Bind individual engines with `M.bind()` (see bottom of file)
--
-- Dependencies:
--   • `vim.ui.open` (Neovim ≥ 0.10) — delegates to xdg-open / open / start
--     https://neovim.io/doc/user/lua.html#vim.ui.open()
--   • `vim.ui.select` — uses whatever picker you have (telescope, fzf, etc.)
--     https://neovim.io/doc/user/lua.html#vim.ui.select()

local M = {}

-- Engine Registry
--
-- Each engine is a named entry with a URL template and a human-readable
-- label. The `%s` placeholder in the URL is replaced with the
-- percent-encoded query string at search time.
--
-- To add a new engine, append a row to this table and optionally
-- bind it to a keymap via `M.bind()` at the bottom of this file.

---@class WebSearchEngine
---@field url string URL template with a single `%s` placeholder for the query
---@field label string Human-readable name shown in the picker and notifications

---@type table<string, WebSearchEngine>
M.engines = {
    -- General
    google = {
        url = 'https://www.google.com/search?q=%s',
        label = 'Google',
    },
    perplexity = {
        url = 'https://www.perplexity.ai/search?q=%s',
        label = 'Perplexity',
    },
    you = {
        url = 'https://you.com/search?q=%s&fromSearchBar=true',
        label = 'You.com',
    },

    -- Code
    github = {
        url = 'https://github.com/search?q=%s&type=code',
        label = 'GitHub Code',
    },
    stackoverflow = {
        url = 'https://stackoverflow.com/search?q=%s',
        label = 'StackOverflow',
    },

    -- C++ Reference
    -- https://en.cppreference.com
    cppreference = {
        url = 'https://en.cppreference.com/mwiki/index.php?search=%s',
        label = 'cppreference',
    },
    -- https://eel.is/c++draft (unofficial but authoritative working-draft mirror)
    cppdraft = {
        url = 'https://eel.is/c++draft/%s',
        label = 'C++ Draft',
    },
    -- Search open-std.org papers via Google site-scoped query
    cppstd = {
        url = 'https://www.google.com/search?q=site:open-std.org+%s',
        label = 'open-std.org',
    },

    -- C++ Tooling
    -- https://quick-bench.com (no query param — opens the homepage)
    quickbench = {
        url = 'https://quick-bench.com/',
        label = 'Quick Bench',
    },

    -- C++ Community
    -- https://www.cppstories.com
    cppstories = {
        url = 'https://www.google.com/search?q=site:cppstories.com+%s',
        label = 'C++ Stories',
    },
    -- Jason Turner's C++ Weekly (YouTube)
    cppweekly = {
        url = 'https://www.google.com/search?q=site:youtube.com+%%22c%%2B%%2B+weekly%%22+jason+turner+%s',
        label = 'C++ Weekly',
    },

    -- CMake
    -- https://cmake.org/cmake/help/latest
    cmake_docs = {
        url = 'https://cmake.org/cmake/help/latest/search.html?q=%s',
        label = 'CMake Docs',
    },

    -- Boost
    -- https://www.boost.org
    boost = {
        url = 'https://www.google.com/search?q=site:boost.org+%s',
        label = 'Boost Docs',
    },
}

---@type string[]|nil
local sorted_keys_cache

---@return string[]
local function get_sorted_keys()
    if not sorted_keys_cache then
        sorted_keys_cache = vim.tbl_keys(M.engines)
        table.sort(sorted_keys_cache)
    end
    return sorted_keys_cache
end

function M.invalidate_cache()
    sorted_keys_cache = nil
end

--- Encode a search query for use in a URL.
---@param raw string
---@return string
local function encode_query(raw)
    local collapsed = raw:gsub('\n', ' ')
    local encoded = vim.uri_encode(collapsed)
    return encoded:gsub('%%20', '+')
end

--- Capture the visual selection RIGHT NOW while visual mode is still active.
---
--- THIS IS THE CRITICAL FUNCTION. It must be called synchronously inside
--- the keymap callback — before vim.ui.select, vim.schedule, or anything
--- else that yields or opens a floating window, because all of those
--- exit visual mode as a side effect, causing getpos("v") to collapse
--- to the cursor position (= one character).
---
--- The `type` parameter tells getregion whether the selection is
--- charwise (v), linewise (V), or blockwise (<C-v>), so all three
--- visual sub-modes are handled correctly.
---
--- https://neovim.io/doc/user/builtin.html#getregion()
--- https://neovim.io/doc/user/builtin.html#getpos()
---@return string
local function capture_visual_selection()
    local mode = vim.fn.mode()
    local lines = vim.fn.getregion(
        vim.fn.getpos('v'),
        vim.fn.getpos('.'),
        { type = mode }
    )
    return table.concat(lines, '\n')
end

--- Resolve search text at keymap invocation time.
---
--- Normal mode: reads the unnamed register (last yank/delete).
--- Visual mode: captures the live selection immediately.
---
--- The returned string is a plain value with no dependency on editor
--- state — safe to pass through async callbacks, pickers, etc.
---@param visual boolean
---@return string
local function resolve_query(visual)
    if visual then
        return capture_visual_selection()
    end
    return vim.fn.getreg('"')
end

--- Open a search engine in the system browser.
---
--- `query` is a pre-resolved plain string. This function never reads
--- visual mode state — it is safe to call from async callbacks.
---
---@param engine_key string Key into `M.engines`
---@param query string Pre-resolved search text
function M.search(engine_key, query)
    local engine = M.engines[engine_key]
    if not engine then
        vim.notify(
            "Web search: unknown engine '" .. engine_key .. "'",
            vim.log.levels.ERROR
        )
        return
    end

    local text = vim.trim(query)
    if text == '' then
        vim.notify(
            'Web search: nothing to search (yank something first)',
            vim.log.levels.WARN
        )
        return
    end

    local url = engine.url:format(encode_query(text))
    vim.ui.open(url)

    local preview = #text > 50 and text:sub(1, 47) .. '...' or text
    vim.notify(('[%s] %s'):format(engine.label, preview), vim.log.levels.INFO)
end

--- Open a picker to choose an engine, then search.
---
--- `query` is captured BEFORE this function opens the picker, so the
--- visual selection is already frozen as a plain string. The picker
--- (vim.ui.select → telescope/fzf/builtin) can freely change editor
--- state without corrupting the search text.
---
---@param query string Pre-resolved search text
function M.pick(query)
    vim.ui.select(get_sorted_keys(), {
        prompt = 'Search with:',
        format_item = function(key)
            return M.engines[key].label
        end,
    }, function(choice)
        if choice then
            M.search(choice, query)
        end
    end)
end

--- Bind one or more engines to keymaps in both normal and visual mode.
---
--- Example:
--- ```lua
--- require("config.web_search").bind({
---   ["<leader>sG"] = { engine = "google",       desc = "Search Google"       },
---   ["<leader>sR"] = { engine = "cppreference", desc = "Search cppreference" },
--- })
--- ```
---
---@class WebSearchKeymapDef
---@field engine string Key into `M.engines`
---@field desc string Keymap description shown in which-key

---@param keymaps table<string, WebSearchKeymapDef>
function M.bind(keymaps)
    for lhs, def in pairs(keymaps) do
        vim.keymap.set('n', lhs, function()
            M.search(def.engine, resolve_query(false))
        end, { desc = def.desc .. ' (yank)' })

        vim.keymap.set('x', lhs, function()
            M.search(def.engine, resolve_query(true))
        end, { desc = def.desc })
    end
end

-- Default Keymaps
-- Text is resolved IMMEDIATELY in the callback, before M.pick opens
-- any floating window. By the time the user picks an engine, the
-- query is already a plain string sitting in a closure.

vim.keymap.set('n', '<leader>sW', function()
    M.pick(resolve_query(false))
end, { desc = 'Web search (pick engine)' })

vim.keymap.set('x', '<leader>sW', function()
    M.pick(resolve_query(true))
end, { desc = 'Web search (pick engine)' })

-- Uncomment to bind individual engines to direct keymaps:
--
-- M.bind({
--   ["<leader>sG"] = { engine = "google",        desc = "Search Google"        },
--   ["<leader>sP"] = { engine = "perplexity",    desc = "Search Perplexity"    },
--   ["<leader>sY"] = { engine = "you",           desc = "Search You.com"       },
--   ["<leader>sH"] = { engine = "github",        desc = "Search GitHub"        },
--   ["<leader>sO"] = { engine = "stackoverflow", desc = "Search StackOverflow" },
--   ["<leader>sR"] = { engine = "cppreference",  desc = "Search cppreference"  },
--   ["<leader>sD"] = { engine = "cppdraft",      desc = "Search C++ Draft"     },
--   ["<leader>sS"] = { engine = "cppstd",        desc = "Search open-std.org"  },
--   ["<leader>sB"] = { engine = "boost",         desc = "Search Boost"         },
--   ["<leader>sC"] = { engine = "cmake_docs",    desc = "Search CMake Docs"    },
-- })

return M
