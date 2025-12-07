-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "<C-j>", "<Esc>", { noremap = true, desc = "Exit insert mode" })
vim.keymap.set("v", "<C-j>", "<Esc>", { noremap = true, desc = "Exit visual mode" })
vim.keymap.set("n", "<S-w>", "$", { noremap = true, desc = "Go to end of line" })
vim.keymap.set("n", "<S-b>", "^", { noremap = true, desc = "Go to beginning of line" })
vim.keymap.set("n", '"', '(iw"', { noremap = true, desc = "Surround word with quotes" })
vim.keymap.set("n", "gh", ":ClangdSwitchSourceHeader<CR>", {
  desc = "Switch between header and source",
  silent = true,
  noremap = true,
})
-- vim.keymap.set("i", "<S-CR>", "<Esc><S-a>;", { noremap = true })
vim.keymap.set("i", "<C-l>", "<Esc>lwi", { noremap = true, desc = "Move cursor forward one word" })
vim.keymap.set("i", "<C-h>", "<Esc>lbi", { noremap = true, desc = "Move cursor backward one word" })
vim.keymap.set("n", "A", function()
  local line = vim.fn.getline(".")
  local row = vim.fn.line(".")
  local semicolon_col = line:find(";%s*$")

  if semicolon_col then
    -- Move cursor before semicolon and enter insert mode
    vim.api.nvim_win_set_cursor(0, { row, semicolon_col - 1 })
    vim.cmd("startinsert")
  else
    -- Simulate a real 'A' keypress (append at end of line)
    vim.api.nvim_feedkeys("A", "n", false)
  end
end, { noremap = true, silent = true, desc = "Append at end (before semicolon if present)" })
