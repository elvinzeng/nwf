--[[
title: NPL web framework loader
author: zenghui
date: 2017/2/27
desc: this file will load NPL web framework basic module and init components.
]]

print('npl web framework is loading...');

NPL.load("(gl)script/ide/Files.lua");
lfs = commonlib.Files.GetLuaFileSystem();
PROJECT_BASE_DIR = lfs.currentdir();
print("project base dir: '" .. PROJECT_BASE_DIR .. "'");

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
NPL.load("nwf.nwf_load_file")

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
print("checking module search path setting...")
for i,v in ipairs(nwf.mod_path) do
    assert(not string.match(v, "^/")
        , "module search path can not be absolute path, use relative path.")
    if (string.match(v, "/$")) then
        nwf.mod_path[i] = string.sub(v, 1, -2);
    end
end

nwf.loadModule = function (mod_base_dir, name)
    local path = mod_base_dir .. '/' .. name;
    if (nwf.initializedModules[name]) then
        print("module '" .. name .. "' already loaded, skipped.");
        return;
    else
        nwf.initializedModules[name] = true;
    end

    local dependenciesConfigPath = path .. '/dependencies.conf';
    if (ParaIO.DoesFileExist(dependenciesConfigPath, false)) then
        local depConfig = assert(io.open(dependenciesConfigPath));
        for line in depConfig:lines() do
            if (not nwf.initializedModules[line]) then
                print("load module '" .. line .."' as a dependency of module '"
                        .. name .."'");
                local moduleFounded = false;
                for i,v in ipairs(nwf.mod_path) do
                    local dep_path = PROJECT_BASE_DIR .. "/" .. v .. "/" .. line;
                    if (ParaIO.DoesFileExist(dep_path, false)) then
                        moduleFounded = true;
                        print("founded dependency on '" .. dep_path .. "'")
                        print("load dependency on '" .. v .. "'");
                        nwf.loadModule(v, line);
                        break;
                    end
                end
                if (not moduleFounded) then
                   error("dependency of module '" .. name .. "' can not found. load failed!");
                end
            end
        end
        depConfig:close();
    end

    print("loading module '" .. name .. "'");
    local initScriptPath = PROJECT_BASE_DIR .. "/" .. path .. '/init.lua';
    --[[local g = {};
    setmetatable(g, {__index = _G})
    local doInit = function()
        NPL.load(initScriptPath);
    end
    setfenv(doInit, g);
    doInit();--]]
    -- NPL.load(initScriptPath);
    nwf.load(initScriptPath);
end

print("load nwf modules...");
local projectDependencies = PROJECT_BASE_DIR .. '/dependencies.conf';
if (ParaIO.DoesFileExist(projectDependencies, false)) then
    local projectDepConfig = assert(io.open(projectDependencies));
    for line in projectDepConfig:lines() do
        if (not nwf.initializedModules[line]) then
            print("load module '" .. line .."' as a dependency of project");
            local moduleFounded = false;
            for i,v in ipairs(nwf.mod_path) do
                local dep_path = PROJECT_BASE_DIR .. "/" .. v .. "/" .. line;
                if (ParaIO.DoesFileExist(dep_path, false)) then
                    moduleFounded = true;
                    print("founded project dependency on '" .. dep_path .. "'")
                    print("load project dependency on '" .. v .. "'");
                    nwf.loadModule(v, line);
                    break;
                end
            end
            if (not moduleFounded) then
                error("project dependency of module '" .. name .. "' can not found. load failed!");
            end
        else
            print("project dependency '" .. line .. "' already loaded, skipped.");
        end
    end
    projectDepConfig:close();
end

print('npl web framework loaded.');
