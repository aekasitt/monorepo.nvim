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
  * Compatible with [Rust](https://rust-lang.org) by investigating `Cargo.toml` file
  * Compatible with [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
    project on [Bun](https://bun.com) runtime by investigating `package.json` file
  * Compatible with [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
    project on [Deno](https://deno.com) runtime by investigating `package.json` file
  * Compatible with [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
    project on [Node](https://bun.com) runtime by investigating `package.json` file
  * Compatible with [Python](https://www.python.org) project managed by
    [uv](https://docs.astral.sh/uv) package and project manager by investigating `pyproject.toml` file
- Toggle visibility of individual workspace members using `<Space>` keypress
- Open members in [fff](https://github.com/dmtrKovalenko/fff.nvim) fuzzy file finder
- Customizable keybindings and window appearance

### Prerequisites

- Works well with a monorepo with one of:
  - `Cargo.toml` with `[workspace]` attribute and `members` array
  - `package.json` with `"workspaces"` array
  - `pyproject.toml` with `[tool.uv.workspaces]` attribute and `members` array

### Installation

1. Using [lazy.nvim](https://github.com/folke/lazy.nvim): 
    <details>
      <summary> Specify configuration file: `~/.config/nvim/lua/init.lua` </summary>
    
      ```lua
      {
        'aekasitt/monorepo.nvim',
        config = function()
          require('monorepo').setup({
            keybinding = '<leader>mn',
            window = {
              border = 'rounded',
              height = 15,
              width = 60,
            },
            fff_integration = true,
          })
        end,
        dependencies = {
          'dmtrKovalenko/fff.nvim',  -- (optional) for quick access
          'nvim-tree/nvim-web-devicons',  -- (optional) for better icons
        },
      }
      ```
    </details>

2. Using [packer.nvim](https://github.com/wbthomason/packer.nvim): 
    <details>
      <summary> Specify configuration file: `~/.config/nvim/lua/plugins.lua` </summary>
    
      ```lua
      use {
        'aekasitt/monorepo.nvim',
        config = function()
          require('monorepo').setup({
            keybinding = '<leader>mn',
            window = {
              border = 'rounded',
              height = 15,
              width = 60,
            },
            fff_integration = true,
          })
        end,
        require = {
          'dmtrKovalenko/fff.nvim',  -- (optional) for quick access
          'nvim-tree/nvim-web-devicons',  -- (optional) for better icons
        },
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
        keybinding = '<leader>mr',
        window = {
          border = 'rounded',
          height = 15,
          width = 60,
        }
      })
      """
      repo = 'aekasitt/monorepo.nvim'
      with = [
        'dmtrKovalenko/fff.nvim',  -- (optional) for quick access
        'nvim-tree/nvim-web-devicons',  -- (optional) for better icons
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
  window = {
    border = 'rounded',  -- 'none', 'single', 'double', 'rounded', 'solid', 'shadow'
    height = 15,
    width = 60,
  },
})
```

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

## License

This project is licensed under the terms of the MIT license.
