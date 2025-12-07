return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", mode = { "n", "t" } },
    { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", mode = { "n", "t" } },
    { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", mode = { "n", "t" } },
    { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", mode = { "n", "t" } },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", mode = { "n", "t" } },
  },
}
