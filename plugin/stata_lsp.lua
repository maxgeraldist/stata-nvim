local data_path = vim.fn.stdpath("data");
local stata_lsp_path = vim.fs.joinpath(data_path, "lazy", "stata-nvim", "lsp-server");
local binary_path = vim.fs.joinpath(stata_lsp_path,
    vim.fn.has("win32") == 1 and "server_bin.exe" or "server_bin");

local function file_exists(path)
    local stat = vim.loop.fs_stat(path);
    return stat and stat.type == "file";
end;

-- Run a command synchronously, blocking until it finishes.
local function run_sync(cmd, args, cwd)
    local output = {};
    local err_output = {};
    local handle = vim.system({ cmd, unpack(args or {}) }, { cwd = cwd, text = true }, function(obj)
        err_output = vim.split(obj.stderr or "", "\n");
        if obj.code ~= 0 then
            vim.schedule(function()
                vim.notify(("Command failed: %s\n%s"):format(cmd, table.concat(err_output, "\n")),
                    vim.log.levels.ERROR);
            end);
        end;
    end);
    handle:wait();
end;

local function compile()
    run_sync("bun", { "build", "./server/src/server.ts", "--compile", "--outfile", "server_bin" },
        stata_lsp_path);
end;

local function install()
    run_sync("npm", { "install" }, stata_lsp_path);
    compile();
end;

local function init()
    run_sync("npm", { "init", "-y" }, stata_lsp_path);
    install();
end;

local function build_binary_server()
    if file_exists(binary_path) then
        return;
    end;
    vim.notify("stata-nvim: building LSP binary", vim.log.levels.INFO);
    init();
    vim.notify("stata-nvim: build complete", vim.log.levels.INFO);
end;

build_binary_server();
