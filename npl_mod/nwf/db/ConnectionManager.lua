--[[
title: NPL web framework connectionManager
author: links
date: 2017/3/6
]]

local connectionManager = commonlib.gettable("nwf.db.connectionManager");
local configUtil = commonlib.gettable("utils.configUtil");

local driver = require("luasql.postgres");
local env = nil;
local dbConfig = configUtil.getConfig("db");

function connectionManager.getConnection()
	if(not env) then
		env = driver.postgres();
	end
	conn = env:connect(dbConfig.database, dbConfig.user_name, dbConfig.user_password, dbConfig.host, dbConfig.port);
	conn:setautocommit(false);
	return conn;
end

function connectionManager.releaseConnection(conn)
	if(conn:close()) then
		
	end
end