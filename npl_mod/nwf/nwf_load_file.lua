--[[
    desc: replace NPL.load, support load file by relative path and absolute path
    author: zenghui
    date: 2017/4/19
]]

local loadedFiles = {};

local function loadFileByAbsolutePath(path)
    if (not loadedFiles[path]) then
        local f = assert(io.open(path, "r"))
        local str = f:read("*all");
        f:close();
        local chk = loadstring(str);
        local g ={}
        local dir, filename = string.match(path, "^(.*)/(.*%.lua)$");
        g["NWF_CURRENT_FILE_PATH"] = path;
        g["NWF_CURRENT_FILE_DIR"] = dir;
        g["NWF_CURRENT_FILE_NAME"] = filename;
        g.load = function(filepath)
            nwf.load(filepath, g["NWF_CURRENT_FILE_DIR"])
        end
        setmetatable(g, {
            __index = _G,
            __newindex = function(t, k, v) _G[k] = v; end
        })
        setfenv(chk, g);
        chk();
        loadedFiles[path] = true;
    end
end


-- load lua file by absolute path or file based relative path
-- @param path: file path
-- @param base_dir: if path is a relative path, base_dir will be base path of path.
-- parameter base_dir will be disable if path is a absolute.
function nwf.load(path, base_dir)
    if (string.match(path, '^/.*') or string.match(path, '^%w:.*')) then
        loadFileByAbsolutePath(path);
    else
        local absolutePath = (base_dir or PROJECT_BASE_DIR) .. "/" .. path;
        loadFileByAbsolutePath(absolutePath);
    end
end