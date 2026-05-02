-- Web search via browse.nvim — cross-platform, telescope-based, minimal config.
-- Replaces the hand-rolled config/web_search.lua module with a maintained plugin.
-- Supports Google, Perplexity, GitHub, StackOverflow, cppreference, C++ Draft,
-- open-std.org, Quick Bench, C++ Stories, C++ Weekly, CMake Docs, and Boost.
-- Ref: https://github.com/lalitmee/browse.nvim
return {
    {
        'lalitmee/browse.nvim',
        dependencies = { 'nvim-telescope/telescope.nvim' },
        opts = {
            provider = 'google',
            bookmarks = {
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
            },
        },
    },
}
