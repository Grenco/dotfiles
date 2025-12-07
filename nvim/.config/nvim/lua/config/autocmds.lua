-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cpp", "typescript", "javascript" },
  callback = function()
    vim.api.nvim_set_keymap("i", "<S-CR>", "<Esc>A;", { noremap = true, silent = true })
  end,
})

-- Dim inactive windows
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  callback = function()
    -- Make inactive windows dimmer
    local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
    if normal_bg then
      -- Darken the background by reducing RGB values
      local r = math.floor((normal_bg / 65536) % 256 * 0.85)
      local g = math.floor((normal_bg / 256) % 256 * 0.85)
      local b = math.floor(normal_bg % 256 * 0.85)
      local dimmed = r * 65536 + g * 256 + b
      vim.api.nvim_set_hl(0, "NormalNC", { bg = dimmed })
    end
    -- Bright cursorline for active window
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#3b4261", bold = true })
  end,
})

-- Show cursorline only in active window
vim.o.cursorline = true
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  callback = function()
    vim.wo.cursorline = true
  end,
})
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  callback = function()
    vim.wo.cursorline = false
  end,
})
