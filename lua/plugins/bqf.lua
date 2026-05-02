-- Professional quickfix enhancement for C++ build workflows.
--
-- nvim-bqf turns the default :copen window into a fuzzy-searchable,
-- preview-enabled, sign-marked panel. Essential for navigating clang
-- / MSVC / GCC build error lists after `:CMakeBuild` or `:make`.
--
-- Features used:
--   * Fzf-like filter inside quickfix
--   * Preview window with syntax highlighting
--   * Sign marks for error/warning/info
--   * Sticky context (keeps cursor position across rebuilds)
--
-- Zero configuration required — upstream defaults are tuned for productivity.
--
-- Ref: https://github.com/kevinhwang91/nvim-bqf

return { 'kevinhwang91/nvim-bqf', ft = 'qf', opts = {} }
