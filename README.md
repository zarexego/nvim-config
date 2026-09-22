# Neovim Config

Personal Neovim configuration built on [lazy.nvim](https://github.com/folke/lazy.nvim).

## Requirements

- Neovim 0.10+
- git
- ripgrep
- base-devel (for Treesitter)
- A Nerd Font

## Installation

git clone https://github.com/zarexego/Config-nvim.git ~/.config/nvim
nvim

Run `:Lazy sync` after first launch.

## Features

- LSP via Mason (pyright, ruff, rust_analyzer, jdtls)
- Autocompletion (nvim-cmp + LuaSnip)
- Treesitter
- Telescope
- nvim-tree
- gitsigns + lazygit
- Format on save (conform.nvim)
- TokyoNight
