# 简介
nwf是一个简单易用的基于NPL的MVC框架。如果你熟悉jsp/servlet或者asp.net mvc，相信你会喜欢上这个框架的。
## 返回一个视图
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
## 返回一个json
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
## 异步响应
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
## 模块化机制
### 列出所有的可用模块
```shell
elvin@elvin-idreamtech ~/temp/nwf/demoproject $ ./nwf_module_manage.sh -a


db_postgres
数据库访问层api-postgres版
-------
helloworld
A demo module for nwf.
-------
```
### 安装模块
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
### 模块管理命令
不带任何参数直接运行模块管理脚本可以看到帮助信息。
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
截至文档更新时，有如上几个参数。最新的参数请以命令输出的信息为准。

# 如何使用
## 创建项目
首先，将你的NPLRuntime更新到最新的版本，然后设置好环境变量。  
接着打开终端执以下命令(Windows下可以在git-bash中执行)：
```shell
~ $ cd ~/workspace
~/workspace $ curl -O https://raw.githubusercontent.com/elvinzeng/nwf/master/nwf_init.sh
~/workspace $ sh ./nwf_init.sh "project-name"  
```
脚本的参数为想要创建的项目的项目名称。初始化脚本会自动创建好目录结构并生成必要的文件。
## 运行服务器
* Linux: sh start.sh
* Windows: 运行update_packages.sh更新包，然后运行start_win.bat。或者直接运行start_win_auto_update.sh。
* 打开浏览器访问"http://localhost:8099/ ". 如果看到页面上显示"it works!"则表示运行成功。

# 其他中文文档
* [创建项目](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/create-project.md)
* [请求映射](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/request-mappings.md)
* [控制器](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/controller.md)
* [校验](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/validation.md)
* [特殊变量](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/special-variables.md)
* [过滤器](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/filter.md)
* [配置](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/settings.md)
* [视图](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/view-template.md)
* [数据库访问](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/database-access.md)
* [模块](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/nwf-module.md)

# 参考文档
* [wiki](https://github.com/elvinzeng/nwf/wiki) — nwf wiki
* [NPL](https://github.com/LiXizhi/NPLRuntime) — Neural Parallel Language
* [NPLPackages main](https://github.com/NPLPackages/main) — NPL Common Lua library
* [lua-resty-template](https://github.com/bungle/lua-resty-template) — Templating Engine
* [lua-resty-validation](https://github.com/bungle/lua-resty-validation) — Validation and filtering library
