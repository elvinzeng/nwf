--[[
title: NPL web framework connectionManager
author: links
date: 2017/3/6
]]

local connectionManager = commonlib.gettable("nwf.modules.db_postgres.connectionManager");
local configUtil = commonlib.gettable("nwf.utils.configUtil");

local driver = require("luasql.postgres");
local env;

function connectionManager.getConnection()
    if (not env) then
        env = driver.postgres();
    end
    local dbConfig = configUtil.getConfig("db");
    local conn = env:connect(dbConfig.database, dbConfig.user_name, dbConfig.user_password, dbConfig.host, dbConfig.port);
    conn:setautocommit(false);
    return conn;
end

function connectionManager.releaseConnection(conn)
    if (conn:close()) then
    end
end
