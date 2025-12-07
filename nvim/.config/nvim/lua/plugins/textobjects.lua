return {
  -- Treesitter configuration
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "bash",
        "c",
        "cpp",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      })
    end,
  },

  -- Textobjects as separate plugin (main branch uses new API)
  -- This overrides LazyVim's default textobjects config
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      select = {
        lookahead = true,
      },
      move = {
        enable = true,
        set_jumps = true,
      },
    },
    config = function(_, opts)
      -- Setup with opts (for move functionality)
      require("nvim-treesitter-textobjects").setup(opts)

      -- Create select keymaps manually (main branch doesn't auto-create from opts)
      local select = require("nvim-treesitter-textobjects.select")
      local swap = require("nvim-treesitter-textobjects.swap")
      local move = require("nvim-treesitter-textobjects.move")

      -- Select keymaps
      vim.keymap.set({ "x", "o" }, "a=", function()
        select.select_textobject("@assignment.outer", "textobjects")
      end, { desc = "Select outer assignment" })
      vim.keymap.set({ "x", "o" }, "i=", function()
        select.select_textobject("@assignment.inner", "textobjects")
      end, { desc = "Select inner assignment" })
      vim.keymap.set({ "x", "o" }, "aL", function()
        select.select_textobject("@assignment.lhs", "textobjects")
      end, { desc = "Select assignment LHS" })
      vim.keymap.set({ "x", "o" }, "aR", function()
        select.select_textobject("@assignment.rhs", "textobjects")
      end, { desc = "Select assignment RHS" })
      vim.keymap.set({ "x", "o" }, "a;", function()
        select.select_textobject("@statement.outer", "textobjects")
      end, { desc = "Select outer statement" })
      vim.keymap.set({ "x", "o" }, "i;", function()
        select.select_textobject("@statement.inner", "textobjects")
      end, { desc = "Select inner statement" })
      vim.keymap.set({ "x", "o" }, "aa", function()
        select.select_textobject("@parameter.outer", "textobjects")
      end, { desc = "Select outer parameter" })
      vim.keymap.set({ "x", "o" }, "ia", function()
        select.select_textobject("@parameter.inner", "textobjects")
      end, { desc = "Select inner parameter" })
      vim.keymap.set({ "x", "o" }, "af", function()
        select.select_textobject("@function.outer", "textobjects")
      end, { desc = "Select outer function" })
      vim.keymap.set({ "x", "o" }, "if", function()
        select.select_textobject("@function.inner", "textobjects")
      end, { desc = "Select inner function" })
      vim.keymap.set({ "x", "o" }, "ac", function()
        select.select_textobject("@class.outer", "textobjects")
      end, { desc = "Select outer class" })
      vim.keymap.set({ "x", "o" }, "ic", function()
        select.select_textobject("@class.inner", "textobjects")
      end, { desc = "Select inner class" })
      vim.keymap.set({ "x", "o" }, "ii", function()
        select.select_textobject("@conditional.inner", "textobjects")
      end, { desc = "Select inner conditional" })
      vim.keymap.set({ "x", "o" }, "ai", function()
        select.select_textobject("@conditional.outer", "textobjects")
      end, { desc = "Select outer conditional" })
      vim.keymap.set({ "x", "o" }, "io", function()
        select.select_textobject("@loop.inner", "textobjects")
      end, { desc = "Select inner loop" })
      vim.keymap.set({ "x", "o" }, "ao", function()
        select.select_textobject("@loop.outer", "textobjects")
      end, { desc = "Select outer loop" })
      vim.keymap.set({ "x", "o" }, "at", function()
        select.select_textobject("@comment.outer", "textobjects")
      end, { desc = "Select outer comment" })
      vim.keymap.set({ "x", "o" }, "i@", function()
        select.select_textobject("@type.inner", "textobjects")
      end, { desc = "Select inner type" })
      vim.keymap.set({ "x", "o" }, "a@", function()
        select.select_textobject("@type.outer", "textobjects")
      end, { desc = "Select outer type" })

      -- Swap keymaps
      vim.keymap.set("n", "<A-l>", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap with next parameter" })
      vim.keymap.set("n", "<A-h>", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap with previous parameter" })

      -- Move keymaps (replacing LazyVim defaults)
      vim.keymap.set({ "n", "x", "o" }, "]f", function()
        move.goto_next_start("@function.outer", "textobjects")
      end, { desc = "Next Function Start" })
      vim.keymap.set({ "n", "x", "o" }, "]c", function()
        move.goto_next_start("@class.outer", "textobjects")
      end, { desc = "Next Class Start" })
      vim.keymap.set({ "n", "x", "o" }, "]a", function()
        move.goto_next_start("@parameter.inner", "textobjects")
      end, { desc = "Next Parameter Start" })
      vim.keymap.set({ "n", "x", "o" }, "]F", function()
        move.goto_next_end("@function.outer", "textobjects")
      end, { desc = "Next Function End" })
      vim.keymap.set({ "n", "x", "o" }, "]C", function()
        move.goto_next_end("@class.outer", "textobjects")
      end, { desc = "Next Class End" })
      vim.keymap.set({ "n", "x", "o" }, "]A", function()
        move.goto_next_end("@parameter.inner", "textobjects")
      end, { desc = "Next Parameter End" })
      vim.keymap.set({ "n", "x", "o" }, "[f", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end, { desc = "Prev Function Start" })
      vim.keymap.set({ "n", "x", "o" }, "[c", function()
        move.goto_previous_start("@class.outer", "textobjects")
      end, { desc = "Prev Class Start" })
      vim.keymap.set({ "n", "x", "o" }, "[a", function()
        move.goto_previous_start("@parameter.inner", "textobjects")
      end, { desc = "Prev Parameter Start" })
      vim.keymap.set({ "n", "x", "o" }, "[F", function()
        move.goto_previous_end("@function.outer", "textobjects")
      end, { desc = "Prev Function End" })
      vim.keymap.set({ "n", "x", "o" }, "[C", function()
        move.goto_previous_end("@class.outer", "textobjects")
      end, { desc = "Prev Class End" })
      vim.keymap.set({ "n", "x", "o" }, "[A", function()
        move.goto_previous_end("@parameter.inner", "textobjects")
      end, { desc = "Prev Parameter End" })
    end,
  },
}
