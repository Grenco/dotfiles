return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "marilari88/neotest-vitest",
  },
  keys = {
    { "<leader>t", "", desc = "Test" },
    {
      "<leader>tf",
      function()
        require("neotest").run.run(vim.fn.expand("%"))
      end,
      desc = "Run all tests in file",
    },
    { "<leader>tr", "<cmd>Neotest run<cr>", desc = "Run test" },
    { "<leader>to", "<cmd>Neotest output<cr>", desc = "Test output" },
    { "<leader>ts", "<cmd>Neotest summary<cr>", desc = "Test summary" },
    {
      "<leader>td",
      function()
        require("neotest").run.run({ strategy = "dap" })
      end,
      desc = "Debug test",
    },

    {
      "<leader>ta",
      function()
        require("neotest").run.run({ suite = true })
      end,
      desc = "Run all tests in suite",
    },
    {
      "[n",
      function()
        require("neotest").jump.prev({ status = "failed" })
      end,
      desc = "Prev failed test",
    },
    {
      "]n",
      function()
        require("neotest").jump.next({ status = "failed" })
      end,
      desc = "Next failed test",
    },
  },
  config = function()
    require("neotest").setup({
      settings = {
        watch = true,
      },
      adapters = {
        require("neotest-vitest"),
      },
    })
  end,
}
