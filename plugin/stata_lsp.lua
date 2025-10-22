local data_path = vim.fn.stdpath("data");
local stata_lsp_path = vim.fs.joinpath(data_path, "lazy", "stata-nvim", "lsp-server");

-- Helper function for running a system command asynchronously
local function run_async(cmd, args, cwd, callback)
    vim.system({ cmd, unpack(args or {}) }, { cwd = cwd }, function(obj)
        if obj.code ~= 0 then
            vim.schedule(function()
                vim.notify(("Command failed: %s\n%s"):format(cmd, obj.stderr), vim.log.levels.ERROR);
            end);
        else
            if callback then
                callback(obj);
            end;
        end;
    end);
end;

local function compile()
    run_async("bun", { "build", "./server/src/server.ts", "--compile", "--outfile", "server_bin" },
        stata_lsp_path);
    vim.schedule(function()
        print("Compiled Stata LSP server");
    end);
end;

local function install()
    run_async("npm", { "install" }, stata_lsp_path, compile);
    vim.schedule(function()
        print("Installed npm dependencies");
    end);
end;

local function file_exists(path)
    local stat = vim.loop.fs_stat(path);
    return stat and stat.type == "file";
end;

local function build_binary_server()
    local binary_path;
    if vim.fn.has("win32") == 1 then
        binary_path = vim.fs.joinpath(stata_lsp_path, "server_bin.exe");
    else
        binary_path = vim.fs.joinpath(stata_lsp_path, "server_bin");
    end;
    if file_exists(binary_path) then
        return;
    end;
    run_async("npm", { "init", "-y" }, stata_lsp_path, function(obj)
        if obj.code == 0 then
            vim.schedule(function()
                print("Initialized npm project");
            end);
            install();
        else
            vim.schedule(function()
                print("npm project already initialized or init failed");
            end);
            install();
        end;
    end);
end;

build_binary_server();
