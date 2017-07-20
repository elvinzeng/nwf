--[[
    DESC:init script for db_postgres module
    Author: links
    Date: 2017/3/6
--]]

print("db_postgres module init...");

NPL.load("(gl)www/modules/db_postgres/ConnectionManager.lua");
NPL.load("(gl)www/modules/db_postgres/DbTemplate.lua");
NPL.load("(gl)www/modules/db_postgres/SqlGenerator.lua");
NPL.load("(gl)www/modules/db_postgres/ResultMapper.lua");
NPL.load("(gl)www/modules/db_postgres/StringUtil.lua");
