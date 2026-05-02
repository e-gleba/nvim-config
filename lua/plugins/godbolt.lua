-- lua/plugins/asmview.lua
-- Assembly / IR viewer via godbolt.nvim — local Compiler Explorer functionality.
-- Replaces ~400 lines of hand-rolled compile_commands.json parsing with a mature
-- plugin that auto-detects flags, provides bidirectional line mapping, and includes
-- an LLVM optimization pipeline viewer.
--
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
            -- Line mapping: bidirectional source ↔ assembly/LLVM IR sync.
            -- Default: enabled=true, auto_scroll=false, throttle_ms=150.
            -- We enable auto_scroll so the opposite pane tracks the cursor.
            -- Ref: https://github.com/lanza/vim-godbolt#line-mapping-godbolt-style
            line_mapping = {
                enabled = true,
                auto_scroll = true,
                throttle_ms = 150,
            },
            -- Display: clean metadata stripping + variable name annotations.
            -- Ref: https://github.com/lanza/vim-godbolt#display-configuration
            display = {
                strip_debug_metadata = true,
                annotate_variables = true,
            },
            -- Pipeline viewer: step through LLVM optimization passes.
            -- Ref: https://github.com/lanza/vim-godbolt#llvm-optimization-pipeline-viewer
            pipeline = {
                enabled = true,
                show_stats = true,
            },
        },
        keys = {
            -- Toggle assembly view for the current buffer.
            -- Forces output="asm" so we always get assembly (not LLVM IR).
            -- Ref: https://github.com/lanza/vim-godbolt#lua-api
            {
                '<leader>caa',
                function()
                    require('godbolt').godbolt('', { output = 'asm' })
                end,
                desc = 'ASM: Toggle',
                ft = { 'c', 'cpp', 'objc', 'objcpp' },
            },
            -- Refresh / reuse the existing assembly window.
            -- Bang (!) reuses the last assembly window for the current source buffer.
            -- Ref: https://github.com/lanza/vim-godbolt#basic-compilation
            {
                '<leader>car',
                '<cmd>Godbolt!<cr>',
                desc = 'ASM: Refresh',
                ft = { 'c', 'cpp', 'objc', 'objcpp' },
            },
            -- Open the LLVM optimization pipeline viewer.
            -- Ref: https://github.com/lanza/vim-godbolt#pipeline-viewer
            {
                '<leader>cap',
                '<cmd>GodboltPipeline<cr>',
                desc = 'ASM: Pipeline',
                ft = { 'c', 'cpp', 'objc', 'objcpp' },
            },
            -- Show the last compilation command used by Godbolt.
            -- Useful for debugging compile_commands.json detection.
            -- Ref: https://github.com/lanza/vim-godbolt#utility-commands
            {
                '<leader>cac',
                '<cmd>GodboltShowCommand<cr>',
                desc = 'ASM: Show compile command',
                ft = { 'c', 'cpp', 'objc', 'objcpp' },
            },
        },
    },
    {
        'folke/which-key.nvim',
        opts = {
            spec = {
                {
                    '<leader>ca',
                    group = 'Assembly',
                    icon = { icon = '', color = 'red' },
                },
            },
        },
    },
}
