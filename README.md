# Dotfiles

Personal configuration files managed with GNU Stow.

## Structure

Each directory represents a stow package that can be independently linked to `~/.config/`:

- `kanata/` - Keyboard remapping configuration
- `nvim/` - Neovim configuration
- `starship/` - Shell prompt configuration
- `tmux/` - Terminal multiplexer configuration

## Usage

Install all configs:
```bash
stow */
```

Install specific config:
```bash
stow nvim
```

Remove a config:
```bash
stow -D nvim
```
