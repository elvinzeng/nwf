--[[
title: NPL web framework connectionManager
author: links
date: 2017/3/6
]]

local connectionManager = commonlib.gettable("nwf.db.connectionManager");

local driver = require("luasql.postgres");
local env = nil;

function connectionManager.getConnection()
	if(not env) then
		env = driver.postgres();
	end
	conn = env:connect("test", "postgres", "123456", "127.0.0.1", "5432");
	conn:setautocommit(false);
	return conn;
end

function connectionManager.releaseConnection(conn)
	if(conn:close()) then
		
	end
end