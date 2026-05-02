# Support

## Getting Help

- **Documentation:** See [LazyVim docs](https://lazyvim.github.io) for editor basics.
- **Plugin upstreams:** Every plugin file in `lua/plugins/` links to its repository.
- **Issues:** Search [existing issues](https://github.com/e-gleba/nvim-config/issues) before opening a new one.

## Common Problems

### Windows -- CRLF / line ending errors

Git on Windows may check out files with `CRLF` (`core.autocrlf=true`). This
config forces `LF` unconditionally via `options.lua`. If an LSP still
complains:

1. Ensure `.gitattributes` in your project has `* text=auto eol=lf`.
2. Re-normalize: `git add --renormalize .`
3. Or set Git globally: `git config --global core.autocrlf false`

### C++ completion not working

`clangd` needs a `compile_commands.json` at project root. Generate it:

```bash
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -s build/compile_commands.json .
```

Then restart Neovim so `clangd` picks it up.
