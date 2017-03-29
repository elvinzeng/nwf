# 什么是特殊变量
为了简化一些高频使用的对象的访问，我们在控制器、校验器中都定义了一些全局变量，方便直接访问。为了方便称呼，特此把它们全称呼为特殊变量。
# 如何访问特殊变量
你可以在控制器和校验器中，在没有定义任何形参的情况下直接访问这些全局变量。
```lua
function demoController.getGV()
        -- you can access these variables
	return {
            requestContext = requestContext,
            ctx = ctx,
            session = session,
            request = request,
            response = response
        };
end
```
# 特殊变量
| 变量名           | 描述信息          |
| ------------------- | ------------------ |
| requestContext    | 请求上下文对象|
| ctx    | 请求上下文对象的别名|
| session    | session|
| request    | 请求对象|
| response    | 响应对象|
