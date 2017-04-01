# Introduction
A simple and easy-to-use MVC framework for NPL Web application. If you are familiar with the jsp/servlet or asp.net mvc, you'll like it.  
[Chinese document](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/index.md)
## return a view
www/controller/DemoController.lua
```lua
local demoController = commonlib.gettable("nwf.controllers.DemoController");

-- http://localhost:8099/demo/sayHello
function demoController.sayHello(ctx)
	-- you can access request, response, session here
	-- local req = ctx.request;
	-- local res = ctx.response;
	-- local session = ctx.session;
	return "test", {message = "Hello, Elvin!"}; -- return www/view/test.html
end
```
www/view/test.html
```html
<!DOCTYPE html>
<html>
<head>
<title>{{title}}</title>
</head>
<body>
  <h1>{{message}}</h1>
</body>
</html>

```
## return json result
www/controller/DemoController.lua
```lua
local demoController = commonlib.gettable("nwf.controllers.DemoController");

--  return json string
function demoController.testJson(ctx)
	return {message = "hello, elvin!", remark = "test json result"};  -- just need to return a table
end
```
Json Result
```json
{"remark":"test json result","message":"hello, elvin!"}
```
## async response
www/controller/PayController.lua
```lua
function payController.getQRCode(ctx)
	local request = ctx.request;
	local string_util = commonlib.gettable("nwf.util.string");
	local tb = { appid = constant.WECHAT_PAY_APPID,
			mch_id = constant.WECHAT_PAY_MCHID,
			nonce_str=string_util.new_guid(),
			body = "xxxxxxxx",
			out_trade_no = 123,
			total_fee = 1 * 100,
			spbill_create_ip = request:getpeername(),
			notify_url = "https://www.xxx.com/api/pay/callback",
			trade_type = "NATIVE",
			product_id = '1111111'};
	tb.sign = sign(tb);
	-- return a async page
	return function (ctx, render)
	   payService.test(tb, function(data)
		   render(data); -- json result
		   --render("test", {message="async response", data=data}) -- view result
	   end)
	end;
end
```
www/service/PayService.lua
```lua
function payService.test(tb, callback)
	System.os.GetUrl({url = "https://api.mch.weixin.qq.com/pay/unifiedorder", 
			form = {data = table2XML(tb) } }, 
			function(status, msg, data)
				local ret = false;
				if(status == 200) then
					ret = luaXml2Table(ParaXML.LuaXML_ParseString(data));
				end
				callback(ret);
			end
		);
end
```
## modular mechanism  
it is easy to reuse functional compoent of website.
### list all available module
```shell
elvin@elvin-idreamtech ~/temp/nwf/demoproject $ ./nwf_module_manage.sh -a


db_postgres
数据库访问层api-postgres版
-------
helloworld
A demo module for nwf.
-------
```
### install
```shell
elvin@elvin-idreamtech ~/temp/nwf/demoproject $ ./nwf_module_manage.sh -i helloworld
Already up-to-date.
Already up-to-date.
module 'helloworld' founded in repository 'nwf'
start install module helloworld...
copy files...
executing www/modules/helloworld/install.sh
helloworld module install...
module helloworld installattion completed.
```
### other commands
```shell
elvin@elvin-idreamtech ~/temp/nwf/demoproject $ ./nwf_module_manage.sh
options:
    -i 'module name'
        install module
    -d 'module name'
        delete module
    -u 'module name'
        reinstall module
    -m
        list all installed modules
    -a
        list all available modules
```
# How to use
## Create Project
First, update you NPLRuntime to latest version and set up environment variables for NPL.  
Now, you only need to run the following command:  
```shell
~ $ cd ~/workspace
~/workspace $ curl -O https://raw.githubusercontent.com/elvinzeng/nwf/master/nwf_init.sh
~/workspace $ sh ./nwf_init.sh "project-name"  
```

Then, this script will use parameter "project-name" to create a directoty as project root directory, it will generate the necessary directory structure and the basic file automatically.  
tips: you can use git-bash to run script if you are Windows user.  
## Run Web Server
* Linux: sh start.sh
* Windows: run update_packages.sh and then run start_win.bat
* Access "http://localhost:8099/ ". "it works!" means web application is start success.

# development documentation
More details you can find in [wiki](https://github.com/elvinzeng/nwf/wiki)
# See Also
* [NPL](https://github.com/LiXizhi/NPLRuntime) — Neural Parallel Language
* [NPLPackages main](https://github.com/NPLPackages/main) — NPL Common Lua library
* [lua-resty-template](https://github.com/bungle/lua-resty-template) — Templating Engine
* [lua-resty-validation](https://github.com/bungle/lua-resty-validation) — Validation and filtering library


<img src="https://analytics.gelvt.com/170331.php?idsite=3&rec=1&action_name=nwf%E9%A1%B9%E7%9B%AE%E9%A6%96%E9%A1%B5" style="border:0" alt="" />
