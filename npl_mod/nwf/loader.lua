--[[
title: NPL web framework loader 
author: zenghui
date: 2017/2/27
desc: this file will load NPL web framework basic module and init components.
]]

print('npl web framework is loading...');

-- init
print("init framework...");
local nwf = commonlib.gettable("nwf");
nwf.controllers = {};
nwf.validators = {};
nwf.config = {};
nwf.template = require "nwf.resty.template";
nwf.validation = require "nwf.resty.validation";
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

print("load builtin modules...");
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

-- load settings
print("load framework settings...");
NPL.load("(gl)www/mvc_settings.lua");

-- load modules
print("load nwf modules...");
NPL.load("(gl)script/ide/Files.lua");
lfs = commonlib.Files.GetLuaFileSystem();
mod_pathes = {}
mod_root_dir = "www/modules"
for entry in lfs.dir(mod_root_dir) do
    if entry ~= '.' and entry ~= '..' then
        local path = mod_root_dir .. '/' .. entry .. '/init.lua';
        print("found module: " .. entry);
        NPL.load(path);
    end
end


print('npl web framework loaded.');
