local M = {};

local function main(opts)
    vim.notify("Starting Stata LSP lafufu", vim.log.levels.INFO);
    opts = opts or { dev = false, stata_license_type = "stata-mp" };
    vim.notify("main() received opts: " .. vim.inspect(opts), vim.log.levels.INFO);
    require('stata-nvim.lsp').setup1(opts);
end;

-- so far, opts has two values:
---- `dev` which is defaulted to false this allows me to test the local repo
----			 without having to push to origin and pull every time
---- `stata_license_type` which is the type of stata license to use.
-- e.g. {dev = false, stata_license_type = "stata-mp"}

function M.setup(opts)
    vim.notify("Starting Stata LSP labubu", vim.log.levels.INFO);
    print(vim.inspect(package.path));

    -- Run immediately if filetype is already set
    if vim.bo.filetype == "stata" then
        vim.notify("Filetype already set to stata — calling main() directly", vim.log.levels.INFO);
        vim.schedule(function()
            main(opts);
        end);
    else
        -- Otherwise, wait for FileType event
        vim.api.nvim_create_autocmd('FileType', {
            pattern = { "stata" },
            once = true,
            callback = function()
                vim.notify("Starting Stata LSP lamumu", vim.log.levels.INFO);
                vim.schedule(function()
                    main(opts);
                end);
            end
        });
    end;
end;

return M;
