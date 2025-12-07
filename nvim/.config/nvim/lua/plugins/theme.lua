-- Smart theme dispatcher: Uses Omarchy if available, falls back to Tokyo Night
local omarchy_theme_path = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")

-- Check if Omarchy theme symlink exists and is valid
local function omarchy_available()
  local stat = vim.loop.fs_stat(omarchy_theme_path)
  return stat ~= nil and stat.type == "file"
end

-- If Omarchy is available, load its theme configuration
if omarchy_available() then
  local ok, theme_config = pcall(dofile, omarchy_theme_path)
  if ok and theme_config then
    return theme_config
  end
  -- If loading fails, fall through to default
  vim.notify("Omarchy theme found but failed to load, using Tokyo Night", vim.log.levels.WARN)
end

-- Fallback: Tokyo Night theme (default settings, no customizations)
return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
