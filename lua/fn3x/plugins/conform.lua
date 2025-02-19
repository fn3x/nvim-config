return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will run multiple formatters sequentially
        go = { "gofumpt" },
        rust = { "rustfmt" },
        sql = { "sql-formatter" },
        -- Use a sub-list to run only the first available formatter
        javascript = { { "prettierd", "prettier" } },
      },
    })

    require("conform").formatters.prettierd = {
      prepend_args = { "--use-tabs", false },
    }
    require("conform").formatters.prettier = {
      prepend_args = { "--use-tabs", false },
    }

    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      callback = function(args)
        local bufnr = args.buf

        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end

        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if string.match(bufname, "/node_modules/") then
          return
        end

        require("conform").format({
          bufnr = bufnr,
          timeout_ms = 500,
          lsp_fallback = true,
          async = false,
        })
      end,
    })
  end,
}
