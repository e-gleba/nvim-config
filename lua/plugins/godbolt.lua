-- vim-godbolt :: disassemble C/C++ inside Neovim via compiler-explorer.com
-- Plugin:     https://github.com/lanza/vim-godbolt
-- README:     https://github.com/lanza/vim-godbolt#readme
-- Wiki:      https://github.com/lanza/vim-godbolt/wiki
-- Issues:    https://github.com/lanza/vim-godbolt/issues
--
-- compile_commands.json auto-detection docs:
-- https://github.com/lanza/vim-godbolt#auto-detection-from-compile_commandsjson

local M = {}

M.supported_filetypes = { 'c', 'cpp', 'objc', 'objcpp' }

M.commands = {
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
}

return {
    {
        'https://github.com/lanza/vim-godbolt.git',
        name = 'godbolt',
        ft = M.supported_filetypes,
        cmd = M.commands,
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
