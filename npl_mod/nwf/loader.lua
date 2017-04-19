--[[
title: NPL web framework loader
author: zenghui
date: 2017/2/27
desc: this file will load NPL web framework basic module and init components.
]]

print('npl web framework is loading...');

-- add search path
NPL.load("(gl)script/ide/System/os/os.lua");
local os_util = commonlib.gettable("System.os");
if(os_util.GetPlatform() == "linux") then
    package.cpath = package.cpath .. ';./lib/so/?.so;'
end
if(os_util.GetPlatform() == "win32") then
    package.cpath = package.cpath .. ';./lib/dll/?.dll;'
end

-- init
print("init framework...");
local nwf = commonlib.gettable("nwf");
nwf.controllers = {};
nwf.validators = {};
nwf.config = {};
nwf.initializedModules = {};
nwf.modules = {};  -- namespace for modules
nwf.requestMappings = {};
nwf.template = require "nwf.resty.template";
nwf.validation = require "nwf.resty.validation";
nwf.mod_path = {"www/modules"}  -- specified module search path
-- init functions
local filters = commonlib.gettable("nwf.filters");

--[[
    nwf.registerFilter(function(ctx, doNext)
        local req = ctx.request;
        local res = ctx.response;
        doSomething();
        doNext();
        doSomething();
    end);
]]
function nwf.registerFilter(filter)
    table.insert(filters, filter);
end;

NPL.load("nwf.utils.configUtil")
NPL.load("nwf.utils.string_util")
NPL.load("nwf.dispatcher")
NPL.load("nwf.utils.string_escape_util")

-- builtin filters
-- register request log filter
nwf.registerFilter(function(ctx, doNext)
    local req = ctx.request;
    --local res = ctx.response;
    local requestPath = req:url();
    local t1 = os.time();
    local ms1 = ParaGlobal.timeGetTime();
    print();
    print(string.format([[[%s] method:[%s] url:[%s] id: [%d]. begin..]]
        , os.date("%c", t1), req:GetMethod(), requestPath, ms1));
    doNext();
    local ms2 = ParaGlobal.timeGetTime();
    print();
    print(string.format([[[%s] method:[%s] url:[%s] id: [%d]. total %d millisec.]]
        , os.date("%c", t1), req:GetMethod(), requestPath, ms1, ms2 - ms1));
end);
-- load session component(filter)
NPL.load("nwf.session");

-- error page controller
nwf.registerRequestMapping("/404", function(ctx)
    return "404";
end);
nwf.registerRequestMapping("/error", function(ctx)
    return "error";
end);

-- load settings
print("load framework settings...");
NPL.load("(gl)www/mvc_settings.lua");

-- load modules
print("load nwf modules...");

nwf.loadModule = function (path, name)
    --print("nwf.loadModule('" .. path .. "', " .. name .. ")");
    if (nwf.initializedModules[name]) then
        print("module '" .. name .. "' already loaded, skipped.");
        return;
    else
        nwf.initializedModules[name] = true;
    end

    local dependenciesConfigPath = path .. '/dependencies.conf';
    if (ParaIO.DoesFileExist(dependenciesConfigPath, false)) then
        local depConfig = io.open(dependenciesConfigPath);
        for line in depConfig:lines() do
            if (not nwf.initializedModules[line]) then
                print("load module '" .. line .."' as a dependency of module '"
                        .. name .."'");
                nwf.loadModule("www/modules/" .. line, line);
            end
        end
        depConfig:close();
    end

    print("loading module '" .. name .. "'")
    local initScriptPath = path .. '/init.lua';
    --[[local g = {};
    setmetatable(g, {__index = _G})
    local doInit = function()
        NPL.load(initScriptPath);
    end
    setfenv(doInit, g);
    doInit();--]]
    NPL.load(initScriptPath);
end

NPL.load("(gl)script/ide/Files.lua");
lfs = commonlib.Files.GetLuaFileSystem();

function load_dir(mod_base_dir)
    for entry in lfs.dir(mod_base_dir) do
        if entry ~= '.' and entry ~= '..' then
            local path = mod_base_dir .. '/' .. entry;
            print("found module: " .. entry);
            nwf.loadModule(path, entry);
        end
    end
end

for i,v in ipairs(nwf.mod_path) do
    print("--------------- loading modules -----------------");
    print("modules base dir: '" .. v .. "'");
    load_dir(v);
    print("--------------- loading modules ------------- end");
end

print('npl web framework loaded.');
