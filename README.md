# Monorepo

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/aekasitt/monorepo.nvim/blob/master/LICENSE)
[![Top](https://img.shields.io/github/languages/top/aekasitt/monorepo.nvim)](https://github.com/aekasitt/monorepo.nvim)
[![Languages](https://img.shields.io/github/languages/count/aekasitt/monorepo.nvim)](https://github.com/aekasitt/monorepo.nvim)
[![Size](https://img.shields.io/github/repo-size/aekasitt/monorepo.nvim)](https://github.com/aekasitt/monorepo.nvim)
[![Last commit](https://img.shields.io/github/last-commit/aekasitt/monorepo.nvim/master)](https://github.com/aekasitt/monorepo.nvim)
[![Fork](https://img.shields.io/badge/fork-aekasitt/fargo.nvim-beige?logo=github)](https://github.com/aekasitt/fargo.nvim)

![Monorepo banner](static/monorepo-banner.svg)

### Features

- Toggle dropdown window showing workspace members
  * Compatible with [JavaScript ![JS](static/javascript.svg)&nbsp;](https://www.w3schools.com/js/)
    or [TypeScript ![TS](static/typescript.svg)&nbsp;](https://www.typescriptlang.org/) project
    on [Bun](https://bun.com),
    [Deno](https://deno.com),
    or [Node](https://bun.com) runtime
    by investigating `package.json` file (prioritizes **TypeScript** if `tsconfig.json` present)
  * Compatible with [Python ![PY](static/python.svg)&nbsp;](https://www.python.org) project managed by
    [uv](https://docs.astral.sh/uv) package and project manager by investigating `pyproject.toml` file
  * Compatible with [Rust ![RS](static/rust.svg)&nbsp;](https://rust-lang.org)
    by investigating `Cargo.toml` file
- Select manifest detection mode:
  * `mono`: use the first detected manifest at repository root
  * `stereo`: combine members from all supported manifests at repository root
- Toggle visibility of individual workspace members using `<Space>` keypress
- Open members in [fff](https://github.com/dmtrKovalenko/fff.nvim) fuzzy file finder
- Customizable keybindings and window appearance

### Prerequisites

- Works well with a monorepo with at least one of:
  - `Cargo.toml` with `[workspace]` attribute and `members` array
  - `package.json` with `"workspaces"` array
  - `pyproject.toml` with `[tool.uv.workspace]` attribute and `members` array
- Detection behavior:
  - `mono` mode: first-match priority is:
    `package.json + tsconfig.json` -> `package.json` -> `pyproject.toml` -> `Cargo.toml`
  - `stereo` mode: parse all detected manifests and merge members into one list (deduped by absolute path)

### Installation

1. Using [built-in](https://echasnovski.com/blog/2025-07-04-neovim-now-has-builtin-plugin-manager.html)
  for [neovim 0.12+](https://github.com/neovim/neovim/pull/34009):
    <details>
      <summary> Specify configuration file: `~/.config/nvim/lua/init.lua` </summary>
    
      ```lua
      vim.pack.add({
        'https://github.com/aekasitt/monorepo.nvim',
        'https://github.com/dmtrKovalenko/fff.nvim',  -- (optional) for quick access
        'https://github.com/nvim-tree/nvim-web-devicons', -- (optional) for better icons
      })
      require('monorepo').setup({
        fff_integration = true,
        keybinding = '<leader>mn',
        window = {
          border = 'rounded',
          height = 15,
          width = 60,
        },
      })
      ```
    </details>

2. Using [lazy.nvim](https://github.com/folke/lazy.nvim): 
    <details>
      <summary> Specify configuration file: `~/.config/nvim/lua/init.lua` </summary>
    
      ```lua
      {
        'aekasitt/monorepo.nvim',
        dependencies = {
          'dmtrKovalenko/fff.nvim',  -- (optional) for quick access
          'nvim-tree/nvim-web-devicons',  -- (optional) for better icons
        },
        opts = {
          fff_integration = true,
          keybinding = '<leader>mn',
          window = {
            border = 'rounded',
            height = 15,
            width = 60,
          },
        }
      }
      ```
    </details>

3. Using [rsplug.nvim](https://github.com/gw31415/rsplug.nvim) : 
    <details>
      <summary> Specify configuration file `~/.config/nvim/rsplug.toml` </summary>
    
      ```toml
      [[plugins]]
      lua_after = """
      require('monorepo').setup({
        fff_integration = true,
        keybinding = '<leader>mn',
        window = {
          border = 'rounded',
          height = 15,
          width = 60,
        }
      })
      """
      repo = 'aekasitt/monorepo.nvim'
      with = [
        'dmtrKovalenko/fff.nvim',  # (optional) for quick access
        'nvim-tree/nvim-web-devicons',  # (optional) for better icons
      ]
      ```
    </details>

### Commands

- `:Monorepo` - Toggle the workspace members dropdown

### Configurations

Defaults:

```lua
require('monorepo').setup({
  fff_integration = true,  -- Use fff.nvim to open crates
  keybinding = '<leader>mn',
  mode = 'mono', -- 'mono' (default) or 'stereo'
  window = {
    border = 'rounded',  -- 'none', 'single', 'double', 'rounded', 'solid', 'shadow'
    height = 15,
    width = 60,
  },
})
```

Mode options:
- `mono` (default): detect one manifest at repository root using priority `Cargo.toml` -> `package.json` -> `pyproject.toml`
- `stereo`: detect every supported manifest at repository root and show a unified member list

#### Default Keybindings

In the dropdown window:
- `<Space>` - Toggle crate visibility
- `<CR>` - Open crate in fff
- `q` or `<Esc>` - Close the dropdown

### Requirements

- Neovim >= 0.8.0
- (Optional) [fff.nvim](https://github.com/dmtrKovalenko/fff.nvim) for fuzzy file finder integration
- (Optional) [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) for better icons

### Acknowledgements

1. [ปริศนา - Prisna](https://www.f0nt.com/release/sov-prisna)
  typeface by [uvSOV - Worawut Thanawatanawanich](https://fb.com/worawut.thanawatanawanich)
2. [fff](https://github.com/dmtrKovalenko/fff.nvim) - The fastest and the most accurate file search
  toolkit for AI agents, Neovim, Rust, C, and NodeJS 
3. [Dmitriy Kovalenko](https://dmtrkovalenko.dev) - Your unFriendly Software Engineer
4. Language icons from [Tiny App Icons Collections](https://www.svgrepo.com/collection/tiny-app-icons/)
  by [SVG Repo](www.svgrepo.com)

## License

This project is licensed under the terms of the MIT license.
