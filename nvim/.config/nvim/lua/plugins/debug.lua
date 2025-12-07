return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "mxsdev/nvim-dap-vscode-js",
  },
  config = function()
    local dap = require("dap")
    local widgets = require("dap.ui.widgets")
    local dapui = require("dapui")
    dapui.setup()
    require("lazydev").setup({
      library = { "nvim-dap-ui" },
    })

    dap.listeners.before.attach.dapui_config = dapui.open
    dap.listeners.before.launch.dapui_config = dapui.open
    dap.listeners.before.event_terminated.dapui_config = dapui.close
    dap.listeners.before.event_exited.dapui_config = dapui.close

    vim.keymap.set("n", "<Leader>d", "<Nop>", { desc = "Debug" })

    vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
    vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
    vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
    vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })

    vim.keymap.set("n", "<Leader>dc", dap.continue, { desc = "Debug: Continue" })
    vim.keymap.set("n", "<Leader>dl", dap.step_over, { desc = "Debug: Step Over" })
    vim.keymap.set("n", "<Leader>dj", dap.step_into, { desc = "Debug: Step Into" })
    vim.keymap.set("n", "<Leader>dk", dap.step_out, { desc = "Debug: Step Out" })
    vim.keymap.set("n", "<Leader>dh", dap.step_back, { desc = "Debug: Step Back" })

    vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    vim.keymap.set("n", "<Leader>dB", dap.set_breakpoint, { desc = "Debug: Set Breakpoint" })

    -- vim.keymap.set("n", "<Leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
    vim.keymap.set("n", "<Leader>dr", dap.run_last, { desc = "Debug: Run Last" })

    vim.keymap.set({ "n", "v" }, "<Leader>dv", widgets.hover, { desc = "Debug: Hover Variables" })
    vim.keymap.set({ "n", "v" }, "<Leader>de", widgets.preview, { desc = "Debug: Preview Expression" })
    vim.keymap.set("n", "<Leader>df", function()
      widgets.centered_float(widgets.frames)
    end, { desc = "Debug: Show Frames" })
    vim.keymap.set("n", "<Leader>ds", function()
      widgets.centered_float(widgets.scopes)
    end, { desc = "Debug: Show Scopes" })

    -- JavaScript/TypeScript DAP Config

    require("dap").adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        args = { vim.fn.stdpath("config") .. "/dap/js-debug/src/dapDebugServer.js", "${port}" },
      },
    }

    dap.configurations.javascript = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug Vitest File",
        runtimeExecutable = "node",
        runtimeArgs = {
          "./node_modules/vitest/vitest.mjs",
          "run",
          "${file}",
          "--inspect-brk",
        },
        skipFiles = { "<node_internals>/**", "node_modules/**" },
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
      },
    }

    dap.configurations.typescript = dap.configurations.javascript
  end,
}
