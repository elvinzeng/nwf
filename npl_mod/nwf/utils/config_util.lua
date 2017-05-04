--[[
Title: ConfigUtil
Date: 2016/9/30
Desc: get config table from webserver.config.xml and WebServer.lua
	  we can define config in webserver.config.xml like this:
	<config>
    <table name='token'>
      <string name='TOKEN_SECRET'>idreamtech1401</string>
      <number name='TOKEN_EXPIRE'>3600000</number>
    </table>
   </config>

   or define in WebServer.lua(server.lua) like this
	self.config.TCPKeepAlive = self.config.TCPKeepAlive == "true";
	self.config.KeepAlive = self.config.KeepAlive=="true";
	self.config.IdleTimeout = self.config.IdleTimeout=="true";
	self.config.IdleTimeoutPeriod = tonumber(self.config.IdleTimeoutPeriod) or 10000
	self.config.compress_incoming = self.config.compress_incoming=="true";
	self.config.debug = self.config.debug=="true"
	self.config.CacheDefaultExpire = self.config.CacheDefaultExpire or 86400;
]]
local ConfigUtil = commonlib.gettable("nwf.utils.configUtil");

function ConfigUtil.getConfig(name)
	if(not name) then
		return WebServer.config;
	else
		return WebServer.config[name];
	end
end