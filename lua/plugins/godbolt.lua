-- Plugin repo : https://github.com/lanza/vim-godbolt
-- Documentation : https://github.com/lanza/vim-godbolt#readme
-- compile_commands.json setup :
-- https://github.com/lanza/vim-godbolt#auto-detection-from-compile_commandsjson

return {
    {
        'lanza/vim-godbolt',
        name = 'godbolt',
        cmd = {
            'Godbolt',
            'GodboltCompiler',
            'GodboltPipeline',
            'GodboltLTO',
            'GodboltLTOPipeline',
            'GodboltLTOCompare',
            'GodboltDebug',
            'GodboltStripOptnone',
            'GodboltShowCommand',
            'NextPass',
            'PrevPass',
            'GotoPass',
            'FirstPass',
            'LastPass',
        },
        ft = { 'c', 'cpp', 'objc', 'objcpp' },
        opts = {
            compile_commands = {
                enabled = true,
                auto_detect = true,
            },
            line_mapping = {
                enabled = true,
                auto_scroll = true,
                throttle_ms = 150,
            },
            display = {
                strip_debug_metadata = true,
                annotate_variables = true,
            },
            pipeline = {
                enabled = true,
                show_stats = true,
            },
        },
    },
}
