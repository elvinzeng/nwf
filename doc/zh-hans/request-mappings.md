# 基本规则
nwf的请求映射规则遵守约定优于配置的规则，主要的映射规则模仿了.NET。
# 具体规则
| 请求路径           | 处理函数          | 示例请求路径 |  示例处理函数  |
| ------------------- | ------------------ | ------------ | ------------ |
| /     | www/controller/RootController.index(ctx); | - |       -     |
| /xxx    | www/controller/RootController.xxx(ctx); | /about | www/controller/RootController.about(ctx); |
| /xxx/    | www/controller/XxxController.index(ctx); | /demo/ | www/controller/DemoController.index(ctx); |
| /xxx/aaa    | www/controller/XxxController.aaa(ctx); | /demo/sayHello | www/controller/DemoController.sayHello(ctx); |
| /aaa/bbb/ccc    | www/controller/aaa/BbbController.ccc(ctx); | /sys/config/update | www/controller/sys/ConfigController.update(ctx); |

你可以嵌套任意层目录，框架会根据请求路径的最后两个部分来搜索controller。
# 显式注册请求映射
API： 

```lua
-- register request mapping
-- @param requestPath: 请求路径
-- @param controllerFunc: 控制器的处理函数
-- @param validatorFunc: 校验器的处理函数
nwf.registerRequestMapping(requestPath, controllerFunc, validatorFunc);

-- register controller
-- @param requestPath: request path
-- @param controllerFunc: function of controller
nwf.registerController(requestPath, controllerFunc);

-- register validator
-- @param requestPath: request path
-- @param validatorFunc: function of validator
nwf.registerValidator(requestPath, validatorFunc)
```

例子：  

```lua
nwf.registerRequestMapping("/aaa/bbb/ccc/ddd", function(ctx)
    return "test", {message = "Hello, Elvin!"};
end, function(params) 
    -- do validation here
    -- return validation result here;
end);


nwf.registerController("/test/a-b/c-d", function()
  return {message="hello elvin!"};
end);

nwf.registerValidator("/test/a-b/c-d", function()
  return true;
end);
```
