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
-- @param requestPath: 请求路径
-- @param controllerFunc: 控制器的处理函数
nwf.registerController(requestPath, controllerFunc);

-- register validator
-- @param requestPath: 请求路径
-- @param validatorFunc: 校验器的处理函数
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

# 在控制器或者校验器脚本文件中显式注册
默认情况下，控制器和校验器脚本文件会在第一个请求到来的时候加载。
这意味着默认情况下在校验器或者控制器脚本文件中显式注册请求映射的功能是不支持的。
如果你需要在控制器或者校验器脚本文件中显式注册控制器、校验器的功能，那么你需要安装模块"preload_controller_mod"。

```shell
$ ./nwf_module_manage.sh -i preload_controller_mod
```

这个模块将会在网站启动的时候扫描项目文件并自动预加载所有的控制器和校验器。
