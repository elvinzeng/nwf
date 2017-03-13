------------------------------------------------------------------
--      desc: Web应用入口文件，如果没有绝对的必要，请勿修改此文件。
--      author: zenghui
--      date: 2017-2-28
------------------------------------------------------------------


-- 加载必要的组建
NPL.load("(gl)script/apps/WebServer/WebServer.lua");
NPL.load("(gl)script/apps/WebServer/mem_cache.lua");
NPL.load("nwf.loader");
NPL.load("(gl)script/ide/System/os/os.lua");

-- 启动web服务器
WebServer:Start("www", "0.0.0.0", 8099);

-- persist pid under linux
local os = commonlib.gettable("System.os");
if(os.GetPlatform() == "linux") then
	local pid = ParaEngine.GetAttributeObject():GetField("ProcessId", 0);
	local file = assert(io.open("server.pid", "w"));
	file:write(pid);
	file:close();
end


NPL.this(function() end);
