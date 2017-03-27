------------------------------------------------------------------
--      desc: MVC框架配置文件
--      author: zenghui
--      date: 2017-3-1
--      attention: 网站启动时将自动执行此文件一次。
--       注意此文件执行之时服务器尚未启动，但是框架已经初始化完毕。
------------------------------------------------------------------
-- local nwf = commonlib.gettable("nwf");
local config = commonlib.gettable("nwf.config");

config.echoDebugInfo = true;  -- 是否在页面上显示调试信息

------------------------------------------------------------------
--  这里加载web应用需要的公共模块
--	e.g. NPL.load("(gl)www/utils/stlutil.lua");
------------------------------------------------------------------


------------------------------------------------------------------
--  这里注册web应用的各种过滤器
------------------------------------------------------------------

--[[
    nwf.registerFilter(function(ctx, doNext)
        local req = ctx.request;
        local res = ctx.response;
        doSomething();
        doNext();
        doSomething();
    end);
]]

