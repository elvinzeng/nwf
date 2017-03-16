--[[
title: NPL web framework loader 
author: zenghui
date: 2017/2/27
desc: this file will load NPL web framework basic module and init components.
]]

print('npl web framework is loading...');

-- init object and load modules
local nwf = commonlib.gettable("nwf");
nwf.controllers = {};
nwf.validators = {};
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

-- load builtin modules
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
    print(string.format([[[%s] method:[%s] url:[%s] id: [%s]. begin..]]
        , os.date("%c", t1), req:GetMethod(), requestPath, req:GetNid()));
    doNext();
    local ms2 = ParaGlobal.timeGetTime();
    print();
    print(string.format([[[%s] method:[%s] url:[%s] id: [%s]. total %d millisec.]]
        , os.date("%c", t1), req:GetMethod(), requestPath, req:GetNid(), ms2 - ms1));
end);
-- load session module(filter)
NPL.load("nwf.session");

-- load settings
NPL.load("(gl)www/mvc_settings.lua");

print('npl web framework loaded.');
