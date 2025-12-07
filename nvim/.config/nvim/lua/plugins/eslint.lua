return {
  "neovim/nvim-lspconfig",
  opts = {
    -- servers = { eslint = {}, tsserver = {}, vtsls = false },
    setup = {
      eslint = function()
        require("snacks").util.lsp.on(function(_, client)
          if client.name == "eslint" then
            client.server_capabilities.documentFormattingProvider = true
            vim.api.nvim_create_autocmd("BufWritePre", {
              callback = function()
                vim.lsp.buf.format()
              end,
            })
          elseif client.name == "tsserver" then
            client.server_capabilities.documentFormattingProvider = false
          elseif client.name == "vtsls" then
            client.server_capabilities.documentFormattingProvider = false
          end
        end)
      end,

      require("conform").setup({
        formatters_by_ft = {
          -- javascript = { "eslint", "eslint_d ", "prettier", "prettierd" },
          -- typescript = { "eslint", "eslint_d ", "prettier", "prettierd" },
          javascript = function(bufnr)
            if vim.fn.filereadable(".eslintrc.js") == 1 or vim.fn.filereadable("eslint.config.js") == 1 then
              return { "eslint_d" }
            else
              return { "prettier" }
            end
          end,
          typescript = function(bufnr)
            if vim.fn.filereadable(".eslintrc.js") == 1 or vim.fn.filereadable("eslint.config.js") == 1 then
              return { "eslint_d" }
            else
              return { "prettier" }
            end
          end,
          cpp = { "clang_format" },
          c = { "clang_format" },
        },
      }),
    },
  },
}
