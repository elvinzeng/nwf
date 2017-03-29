# 文件和处理函数
根据[请求映射规则](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/request-mappings.md)，把你的控制器文件放到对应的目录下，并在控制器文件中写好对应的函数。
# request context
在本文中，我把控制器里面用于处理请求的每个函数叫做一个action。每个action都有一个参数，ctx。这是一个table。大概的结构像下面这样：  
```lua
{
    request = {},
    response = {},
    session = {id = "xxxxxxx"},
    validation = {isValid = false, fields = {}, isEnabled = true}
}
```
# action的返回值
action的返回值个数以及类型将会决定这个请求的响应类型。
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
## 重定向
www/controller/DemoController.lua
```lua
local demoController = commonlib.gettable("nwf.controllers.DemoController");

-- send recirect
function demoController.testRedirect(ctx)
        return "redirect:/demo/sayHello";
end
```
## 特殊变量
参考 [special variables](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/special-variables.md).
