return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  lazy = false,
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    local conf = require("telescope.config").values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require("telescope.pickers")
        .new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table({
            results = file_paths,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        })
        :find()
    end

    local harpoon_extensions = require("harpoon.extensions")
    harpoon:extend(harpoon_extensions.builtins.highlight_current_file())

    vim.keymap.set("n", "<leader>h", function() end, { desc = "Harpoon" })
    vim.keymap.set("n", "<leader>ha", function()
      harpoon:list():add()
    end, { desc = "Add buffer to harpoon" })
    vim.keymap.set("n", "<C-e>", function()
      toggle_telescope(harpoon:list())
    end, { desc = "Open harpoon window" })
    vim.keymap.set("n", "<leader>hd", function()
      harpoon:list():remove()
    end, { desc = "Harpoon delete buffer" })
    vim.keymap.set("n", "<leader>hq", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Harpoon quick menu" })
    vim.keymap.set("n", "<C-1>", function()
      harpoon:list():select(1)
    end)
    vim.keymap.set("n", "<C-2>", function()
      harpoon:list():select(2)
    end)
    vim.keymap.set("n", "<C-3>", function()
      harpoon:list():select(3)
    end)
    vim.keymap.set("n", "<C-4>", function()
      harpoon:list():select(4)
    end)

    vim.keymap.set("n", "<C-P>", function()
      harpoon:list():prev()
    end)
    vim.keymap.set("n", "<C-N>", function()
      harpoon:list():next()
    end)
  end,
}
