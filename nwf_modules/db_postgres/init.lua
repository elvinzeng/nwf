--
-- init script for helloworld module
-- Author: elvin
-- Date: 17-3-24
-- Time: 10:46
-- desc: this script will be load at mvc framework loaded..
--

print("driver module init...");

NPL.load("(gl)www/modules/db_postgres/ConnectionManager.lua");
NPL.load("(gl)www/modules/db_postgres/DbTemplate.lua");
NPL.load("(gl)www/modules/db_postgres/SqlGenerator.lua");
NPL.load("(gl)www/modules/db_postgres/ResultMapper.lua");
