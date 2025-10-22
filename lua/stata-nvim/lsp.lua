local M = {};

function M.setup1(opts)
    vim.notify("entered setup1", vim.log.levels.INFO);
    opts = opts or {};
    local dev = opts.dev or false;

    local lsp_path = dev
        and vim.fn.expand("~/Documents/plugins/stata-nvim/lsp-server/server_bin")
        or vim.fn.expand(vim.fn.stdpath("data") .. "/lazy/stata-nvim/lsp-server/server_bin");
    vim.notify("used a dummy", vim.log.levels.INFO);

    if vim.bo.filetype == "stata" then
        vim.notify("filetype already set — starting LSP directly", vim.log.levels.INFO);
        vim.schedule(function()
            vim.notify("in autocmd inner (manual trigger)", vim.log.levels.INFO);
            vim.lsp.start({
                name = "stata",
                cmd = { lsp_path },
                root_dir = vim.fn.getcwd(),
                filetypes = { "stata" },
                on_attach = function(client)
                    print("Stata LSP attached (native)");
                end,
                capabilities = vim.lsp.protocol.make_client_capabilities(),
            });
        end);
    else
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "stata",
            callback = function()
                vim.notify("in autocmd outer", vim.log.levels.INFO);
                vim.schedule(function()
                    vim.notify("in autocmd inner", vim.log.levels.INFO);
                    vim.lsp.start({
                        name = "stata",
                        cmd = { lsp_path },
                        root_dir = vim.fn.getcwd(),
                        filetypes = { "stata" },
                        on_attach = function(client)
                            print("Stata LSP attached (native)");
                        end,
                        capabilities = vim.lsp.protocol.make_client_capabilities(),
                    });
                end);
            end,
        });
    end;
end;

return M;
