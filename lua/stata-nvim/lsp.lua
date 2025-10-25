local M = {};

function M.setup(opts)
    opts = opts or {};
    local dev = opts.dev or false;

    local lsp_path = dev
        and vim.fn.expand("~/Documents/plugins/stata-nvim/lsp-server/server_bin")
        or vim.fn.expand(vim.fn.stdpath("data") .. "/lazy/stata-nvim/lsp-server/server_bin");

    if vim.bo.filetype == "stata" then
        vim.schedule(function()
            vim.lsp.start({
                name = "stata",
                cmd = { lsp_path },
                root_dir = vim.fn.getcwd(),
                filetypes = { "stata" },
                on_attach = function(client)
                end,
                capabilities = vim.lsp.protocol.make_client_capabilities(),
            });
        end);
    else
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "stata",
            callback = function()
                vim.schedule(function()
                    vim.lsp.start({
                        name = "stata",
                        cmd = { lsp_path },
                        root_dir = vim.fn.getcwd(),
                        filetypes = { "stata" },
                        on_attach = function(client)
                        end,
                        capabilities = vim.lsp.protocol.make_client_capabilities(),
                    });
                end);
            end,
        });
    end;
end;

return M;
